require "cli-format"

class Jets::CLI
  class Url < Base
    rescue_api_error

    def run
      if @options[:format] == "json"
        puts data.to_json # simpler json format allows for: jets url | jq
      else
        present(data)
      end
    end

    private

    def present(items)
      presenter = CliFormat::Presenter.new(@options)
      presenter.empty_message = "No url info found"
      presenter.header = ["Name", "Value"] if @options[:header] # default: false
      puts "data #{data}".color(:purple)
      data.keys.sort.each do |name|
        next if name.to_s == "queue_url" # dont show Queue Url
        name_url = name.to_s.titleize
        value = data[name]
        row = [name_url, value]
        presenter.rows << row
      end
      presenter.show
    end

    def data
      release = Release::Info.new(@options).get
      data = release.endpoints.inject({}) do |acc, endpoint|
        acc.merge!(endpoint[:name] => endpoint[:url])
      end
      data.delete_if { |k, v| v.nil? } # remove nil values
      data.delete_if { |k| k.include?("queue_url") } unless @options[:all]
      data
    end
    memoize :data
  end
end
