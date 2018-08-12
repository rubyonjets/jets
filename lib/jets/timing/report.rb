require 'json'

module Jets::Timing
  class Report
    extend Memoist

    def initialize(log=Jets::Timing::RECORD_LOG_PATH)
      @log = log
    end

    def result
      unless File.exist?(@log)
        puts "WARN: Timing #{@log} does not exist"
        return
      end
      process
    end

    def process
      deploy = times_for("Jets::Commands::Deploy")
      deploy[:rest] = rest_time(deploy[:run], deploy[:build_code], deploy[:ship])
      build = times_for("Jets::Commands::Build")
      ship = times_for("Jets::Cfn::Ship")
      code = times_for("Jets::Builders::CodeBuilder")

      # Two ships screw this up.
      # The first ship creates the base parent stack with the s3 bucket.
      # The second ship creates the app.
      # Once the first stack exists, it is left alone and ship does not get called
      # twice.
      # This reporting logic currenly only reports the last ship.
      results =<<-EOL
deploy: #{deploy[:run]} 100%
  build_code: #{deploy[:build_code]} #{percent(deploy[:build_code], deploy[:run])}
    build_code: #{build[:build_code]} #{percent(build[:build_code], deploy[:build_code])}
      bundle_install: #{code[:bundle_install]} #{percent(code[:bundle_install], code[:build])}
      compile_assets: #{code[:compile_assets]} #{percent(code[:compile_assets], code[:build])}
      copy_project: #{code[:copy_project]} #{percent(code[:copy_project], code[:build])}
      create_zip_file: #{code[:create_zip_file]} #{percent(code[:create_zip_file], code[:build])}
      finish_app_root_setup: #{code[:finish_app_root_setup]} #{percent(code[:finish_app_root_setup], code[:build])}
      start_app_root_setup: #{code[:start_app_root_setup]} #{percent(code[:start_app_root_setup], code[:build])}
    build_templates: #{build[:build_templates]} #{percent(build[:build_templates], deploy[:build_code])}
  ship: #{deploy[:ship]} #{percent(deploy[:ship], deploy[:run])}
    update_stack: #{ship[:update_stack]} #{percent(ship[:update_stack], deploy[:ship])}
    upload_to_s3: #{ship[:upload_to_s3]} #{percent(ship[:upload_to_s3], deploy[:ship])}
    wait_for_stack: #{ship[:wait_for_stack]} #{percent(ship[:wait_for_stack], deploy[:ship])}
  rest: #{deploy[:rest]} #{percent(deploy[:rest], deploy[:run])}
EOL
      results.split("\n").reject { |l| l.empty? }.join("\n")
    end

    # All times for a class
    def times_for(class_name)
      times = data.select { |i| i['class'] == class_name }
      meths = times.map { |i| i['meth'] }.uniq
      meths.inject({}) do |result, meth|
        result.merge(meth => time_for(class_name, meth))
      end.deep_symbolize_keys
    end

    def data
      IO.readlines(@log).map { |l| JSON.load(l) }
    end
    memoize :data

    # Returns String
    # Example: 88%
    def percent(num, denom)
      '%.2f' % (num.to_f / denom.to_f * 100) + '%'
    end

    def rest_time(total, *times)
      result = total.to_f
      times.each { |time| result -= time.to_f }
      '%.3f' % result + 's'
    end

    # Returns String
    # Example: 88.8s
    def time_for(klass, meth)
      timings = data.select { |l| l['class'] == klass && l['meth'] == meth }
      start_time = get_time(timings, 'start')
      finish_time = get_time(timings, 'finish')
      diff = ( finish_time - start_time ) / 1000.0
      '%.3f' % diff + 's'
    end

    # Input: timings is a pair of data. The start and end time.
    def get_time(timings, type)
      # reverse so we get the last ship
      time = timings.reverse.find { |l| l['type'] == type }['time']
      time.to_f # in milloseconds
    end
  end
end
