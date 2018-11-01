module Jets::Gems
  class Report
    def self.missing(gems)
      new(gems).report
    end

    def initialize(gems)
      @gems = gems
    end

    def report
      @gems.each do |gem_name|
        # puts "Send API call to report missing gem: #{gem_name}"
      end
    end
  end
end
