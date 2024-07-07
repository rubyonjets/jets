class Jets::CLI::Exec::Lambda::Repl
  class History
    MAX_SIZE = 10_000

    attr_reader :list
    def initialize(options = {})
      @options = options
      @file = "#{ENV["HOME"]}/.jets/history"
      @list = load
    end

    def add(cmd)
      @list << cmd
      @list.shift if @list.size > MAX_SIZE
    end

    def display(num = nil)
      num ||= 20
      num = (num == "all") ? @list.length : num.to_i
      num = [@list.length, num].min
      start_index = [@list.length - num, 0].max
      @list[start_index..].each_with_index { |cmd, index| puts "#{start_index + index + 1}: #{cmd}" }
    end

    def load
      history = if File.exist?(@file)
        File.readlines(@file).map(&:chomp)
      else
        []
      end
      history.each { |cmd| Readline::HISTORY << cmd }
      history
    end

    def save
      FileUtils.mkdir_p(File.dirname(@file))
      File.open(@file, "w") do |file|
        @list.each { |cmd| file.puts cmd }
      end
    end
  end
end
