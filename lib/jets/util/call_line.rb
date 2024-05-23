module Jets::Util
  module CallLine
    include Pretty

    def jets_call_line
      caller.find { |l| l.include?("#{Jets.root}/") }
    end
  end
end
