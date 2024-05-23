module Jets::Util
  module Pretty
    def pretty_path(path)
      path.sub("#{Jets.root}/", "").sub(/^\.\//, "")
    end

    # Replace HOME with ~ - different from the main pretty_path
    def pretty_home(path)
      path.sub(ENV["HOME"], "~")
    end

    # http://stackoverflow.com/questions/4175733/convert-duration-to-hoursminutesseconds-or-similar-in-rails-3-or-ruby
    def pretty_time(total_seconds)
      minutes = (total_seconds / 60) % 60
      seconds = total_seconds % 60
      if total_seconds < 60
        "#{seconds.to_i}s"
      else
        "#{minutes.to_i}m #{seconds.to_i}s"
      end
    end
  end
end
