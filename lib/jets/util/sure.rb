module Jets::Util
  module Sure
    private

    def sure?(message = nil)
      confirm = "Are you sure?"
      if @options[:yes]
        yes = "y"
      else
        out = if message
          "#{message}\n#{confirm} (y/N) "
        else
          "#{confirm} (y/N) "
        end
        print out
        yes = $stdin.gets
      end

      unless /^y/.match?(yes)
        puts "Whew! Exiting."
        exit 0
      end
    end
  end
end
