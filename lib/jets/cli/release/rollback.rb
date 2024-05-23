class Jets::CLI::Release
  class Rollback < Base
    rescue_api_error

    def run
      version = @options[:version]
      resp = Info.new(@options).get(version)
      unless resp[:version]
        puts "ERROR: version #{version} not found".color(:red)
        exit 1
      end
      Jets::Cfn::Rollback.new(@options).run
    end
  end
end
