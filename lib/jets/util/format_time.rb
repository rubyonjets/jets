module Jets::Util
  module FormatTime
    def pretty_time(utc)
      utc = DateTime.parse(utc) if utc.is_a?(String)

      if utc > 1.day.ago.utc
        time_ago_in_words(utc) + " ago"
      else
        tz_override = ENV["JETS_TZ"] # IE: America/Los_Angeles
        local = if tz_override
          tz = TZInfo::Timezone.get(tz_override)
          tz.utc_to_local(utc)
        else
          utc.new_offset(DateTime.now.offset) # local time
        end

        if tz_override
          local.strftime("%b %-d, %Y %-l:%M:%S%P")
        else
          local.strftime("%b %-d, %Y %H:%M:%S")
        end
      end
    end

    # Simple implementation of time_ago_in_words so we dont have to include ActionView::Helpers::DateHelper
    def time_ago_in_words(from_time, to_time = Time.now)
      distance_in_seconds = (to_time - from_time).to_i
      case distance_in_seconds
      when 0..59
        "#{distance_in_seconds} #{"second".pluralize(distance_in_seconds)}"
      when 60..3599
        minutes = distance_in_seconds / 60
        "#{minutes} #{"minute".pluralize(minutes)}"
      when 3600..86_399
        hours = distance_in_seconds / 3600
        "#{hours} #{"hour".pluralize(hours)}"
      when 86_400..604_799
        days = distance_in_seconds / 86_400
        "#{days} #{"day".pluralize(days)}"
      else
        from_time.strftime("%B %d, %Y")
      end
    end
  end
end
