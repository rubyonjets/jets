require 'json'

module Jets::Timing
  class Report
    extend Memoist

    def initialize(log=Jets::Timing::RECORD_LOG_PATH)
      @log = log
    end

    def results
      unless File.exist?(@log)
        puts "WARN: Timing #{@log} does not exist"
        return
      end
      puts process
    end

    def process
      deploy = times_for("Jets::Commands::Deploy")
      deploy[:rest] = rest_time(deploy[:run], deploy[:build_code], deploy[:ship])
      build = times_for("Jets::Commands::Build")
      cfn_ship = times_for("Jets::Cfn::Ship")
      code_builder = times_for("Jets::Builders::CodeBuilder")

      # Two ships screw this up.
      # The first ship creates the base parent stack with the s3 bucket.
      # The second ship creates the app.
      # Once the first stack exists, it is left alone and ship does not get called
      # twice.
      # This reporting logic currently only reports the last ship.
      # Refer to timings.reverse.find in get_time method.
      results = {
        overall: deploy[:run],
        "commands/deploy.rb": deploy,
        "commands/build.rb": build,
        "builders/code_builder.rb": code_builder,
        "cfn/ship.rb": cfn_ship,
      }
      text = YAML.dump(results.deep_stringify_keys)
      text.sub!('---', 'Timing report:')
      text
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
