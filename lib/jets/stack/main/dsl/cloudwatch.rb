module Jets::Stack::Main::Dsl
  module Cloudwatch
    def cloudwatch_alarm(id, hash={})
      if hash.key?(:depends_on)
        attributes = hash # leave structure alone and add type only
        attributes[:type] = "AWS::CloudWatch::Alarm"
      else
        # the attributes are properties
        properties = hash
        attributes = {
          type: "AWS::CloudWatch::Alarm",
          properties: properties,
        }
      end
      resource(id, attributes)
      output(id)
    end
  end
end