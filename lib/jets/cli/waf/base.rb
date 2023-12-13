class Jets::CLI::Waf
  class Base < Jets::CLI::Base
    def stack_name
      [Jets::CLI::Waf.waf_name, "waf"].compact.join("-")
    end
  end
end
