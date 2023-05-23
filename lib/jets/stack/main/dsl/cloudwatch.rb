module Jets::Stack::Main::Dsl
  module Cloudwatch
    def cloudwatch_alarm(id, hash={})
      if hash.key?(:DependsOn)
        attributes = hash # leave structure alone and add type only
        attributes[:Type] = "AWS::CloudWatch::Alarm"
      else
        # the attributes are properties
        properties = hash
        attributes = {
          Type: "AWS::CloudWatch::Alarm",
          Properties: properties,
        }
      end
      resource(id, attributes)
      output(id)
    end
  end
end