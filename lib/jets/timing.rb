require 'fileutils'
require 'json'
require 'active_support/concern'

# Used to record timing on how long `jets deploy` takes.
# So we can continually improve it.
#
# We inject timing code into choosen methods and then record the start and finish
# time for those methods in /tmp/jets/demo/timing/records.log. Each item in the log
# is in JSON.
#
# We later use the data in this log to generate a timing report.
module Jets
  module Timing
    autoload :Report, 'jets/timing/report'
    extend ActiveSupport::Concern
    RECORD_LOG_PATH = "#{Jets.build_root}/timing/records.log"

    def record_data(meth, type)
      # https://stackoverflow.com/questions/17267935/display-time-down-to-milliseconds-in-ruby-1-8-7
      # Record time in milliseconds unit so we can calculate time differences later
      time = (Time.now.to_f * 1000.0).to_i
      JSON.dump(
        class: self.class.name,
        meth: meth,
        time: time,
        type: type,
      )
    end

    def record_log(meth, type)
      data = record_data(meth, type)
      path = Timing::RECORD_LOG_PATH
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'a') {|f| f.write(data + "\n") }
    end

    # Clear out all timing data
    def self.clear
      return unless File.exist?(RECORD_LOG_PATH)
      FileUtils.cp("/dev/null", RECORD_LOG_PATH)
    end

    def self.report
      return unless ENV['JETS_TIMING']
      Report.new.results
    end

    included do
      def self.time(meth)
        unrecorded_meth = "unrecorded_#{meth}"
        alias_method unrecorded_meth, meth

        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def #{meth}(*args, &block)
            record_log(:#{meth}, :start)
            result = #{unrecorded_meth}(*args, &block)
            record_log(:#{meth}, :finish)
            result
          end
        EOS
      end
    end
  end
end