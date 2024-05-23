# post process the text so that
# "!Ref IamRole" => !Ref IamRole
# We strip the surrounding quotes
module Jets::Cfn::Builder
  class PostProcess
    def initialize(text)
      @text = text
    end

    def process
      results = @text.split("\n").map do |line|
        if line.include?(': "!') # IE: IamRole: "!Ref IamRole",
          # IamRole: "!Ref IamRole" => IamRole: !Ref IamRole
          line.sub(/: "(.*)"/, ': \1')
        elsif line.include?('- "!') # IE: - "!GetAtt Foo.Arn"
          # IamRole: - "!GetAtt Foo.Arn" => - !GetAtt Foo.Arn
          line.sub(/- "(.*)"/, '- \1')
        else
          line
        end
      end
      results.join("\n") + "\n"
    end
  end
end
