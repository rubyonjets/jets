module Jets::Gems
  class Report
    LAMBDAGEM_API_URL = ENV["LAMBDAGEM_API_URL"] || "https://api.lambdagems.com/api/v1"

    def self.missing(gems)
      new(gems).report
    end

    def initialize(gems)
      @gems = gems
    end

    def report
      version_pattern = /(.*)-(\d+\.\d+\.\d+.*)/
      @gems.each do |gem_name|
        if md = gem_name.match(version_pattern)
          name, version = md[1], md[2]
          puts api("report/missing?name=#{name}&version=#{version}")
        else
          puts "WARN: Unable to extract the version from the gem name."
        end
      end
    end

    def api(path)
      "#{LAMBDAGEM_API_URL}/#{path}"
    end
  end
end
