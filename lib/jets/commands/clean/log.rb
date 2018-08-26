# The thing that limits this implementation is that there needs to be at least
# one lambda function created from an internal jets function. Example:
#
#   /aws/lambda/demo-dev-2-jets-preheat_job-warm
#   /aws/lambda/demo-dev-2-jets-public_controller-show
#
# We're doing this because JETS_ENV_EXTRA environments can create additional matching
# log groups and we don't want to overly-aggressively delete them.
#
# The `keep_prefixes(log_group_names)` method calcuates the log groups to keep.
class Jets::Commands::Clean
  class Log < Base
    extend Memoist
    include Jets::AwsServices

    def clean
      are_you_sure?("delete CloudWatch logs")

      say "Removing CloudWatch logs for #{prefix_guess}..."
      log_groups.each do |g|
        next if keep_log_group?(g.log_group_name)
        logs.delete_log_group(log_group_name: g.log_group_name) unless @options[:noop]
        say "Removed log group: #{g.log_group_name}"
      end
      say "Removed CloudWatch logs for #{prefix_guess}"
    end

  private
    def prefix_guess
      Jets::Naming.parent_stack_name
    end

    def log_groups
      groups, next_token = [], true
      while next_token
        next_token = nil if next_token == true # just at start the loop
        resp = logs.describe_log_groups(
          log_group_name_prefix: "/aws/lambda/#{prefix_guess}-",
          next_token: next_token,
        )
        groups += resp.log_groups
        next_token = resp.next_token
      end
      groups
    end
    memoize :log_groups

    def log_group_names
      log_groups.map(&:log_group_name)
    end

    def all_prefixes(log_group_names)
      log_prefixes(log_group_names)
    end
    memoize :all_prefixes

    # Check for the prefixes to keep. The slightly tricky thing to watch for is
    # for the prefix matching addiitonal log groups that belong to other
    # JETS_ENV_EXTRA=xxx created environments.
    #
    # We find and store the prefixes to keep so we don't over aggressively delete
    # log groups.
    def keep_prefixes(log_group_names)
      names = log_group_names.reject do |name|
        name =~ %r{/aws/lambda/#{prefix_guess}-jets}
      end
      log_prefixes(names)
    end
    memoize :keep_prefixes

    # Strips -jets.* from the full log group name to leave only the prefix behind
    def log_prefixes(names)
      names = names.select do |name|
        name.match(Regexp.new("#{prefix_guess}-.*jets"))
      end
      names.map do |name|
        name.sub(/-jets.*/,'')
      end.uniq.sort
    end

    # Check if it is safe to delete the log group
    def keep_log_group?(log_group_name)
      keep_prefixes = keep_prefixes(log_group_names)
      !!keep_prefixes.detect do |keep_prefix|
        log_group_name =~ Regexp.new(keep_prefix)
      end
    end
  end
end
