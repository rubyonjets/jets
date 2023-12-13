module Jets::Code::Copy
  # Inherits from Base for build_root and class run method
  class Full < Base
    # Completely override run since Full has complete different behavior
    def run
      FileUtils.cp_r(Jets.root, "#{build_root}/stage/code")
    end
  end
end
