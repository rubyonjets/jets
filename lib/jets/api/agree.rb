module Jets::Api
  class Agree
    def initialize
      @agree_file = "#{ENV["HOME"]}/.jets/agree"
    end

    # Only prompts if hasnt prompted before and saved a ~/.jets/agree file
    def prompt
      return if bypass_prompt
      return if File.exist?(@agree_file) && File.mtime(@agree_file) > Time.parse("2021-04-12")

      puts <<~EOL
        To use jets you must agree to the terms of service.

        Jets Terms: https://www.rubyonjets.com/terms

        Is it okay to send your gem data to Jets Api? (Y/n)?
      EOL

      answer = $stdin.gets.strip
      value = /y/i.match?(answer) ? "yes" : "no"

      write_file(value)
    end

    # Allow user to bypass prompt with JETS_AGREE=1 JETS_AGREE=yes etc
    # Useful for CI/CD pipelines.
    def bypass_prompt
      agree = ENV["JETS_AGREE"]
      return false unless agree

      if %w[1 yes true].include?(agree.downcase)
        write_file("yes")
      else
        write_file("no")
      end

      true
    end

    def yes?
      File.exist?(@agree_file) && IO.read(@agree_file).strip == "yes"
    end

    def no?
      File.exist?(@agree_file) && IO.read(@agree_file).strip == "no"
    end

    def yes!
      write_file("yes")
    end

    def no!
      write_file("no")
    end

    def write_file(content)
      FileUtils.mkdir_p(File.dirname(@agree_file))
      IO.write(@agree_file, content)
    end
  end
end
