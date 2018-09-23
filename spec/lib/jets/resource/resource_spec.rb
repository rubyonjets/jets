describe Jets::Resource do
  let(:resource) { Jets::Resource.new(definition, replacements) }

  context "long form resource with no replacements" do
    let(:replacements) { {} }
    let(:definition) do
      {
        "RestApi": {
          type: "AWS::ApiGateway::RestApi",
          properties: {
            name: "demo-test"
          }
        }
      }
    end

    it "cloudformation format" do
      # pp resource # uncomment to see and debug
      # pp resource.attributes # uncomment to see and debug
      # pp resource.properties # uncomment to see and debug
      expect(resource.logical_id).to eq "RestApi"
      expect(resource.type).to eq "AWS::ApiGateway::RestApi"
      properties = resource.properties
      expect(properties['Name']).to eq "demo-test"
    end
  end

  context "long form resource with replacements" do
    let(:replacements) do
      { namespace: "SecurityJobCheck" }
    end
    let(:definition) do
      {
        "{namespace}EventsRule": {
          type: "AWS::Events::Rule",
          properties: {
            event_pattern: {
              detail_type: ["AWS API Call via CloudTrail"],
              detail: {
                event_source: ["ec2.amazonaws.com"],
                event_name: [
                  "AuthorizeSecurityGroupIngress",
                ]
              }
            },
            state: "ENABLED",
            targets: [{
              arn: "!GetAtt {namespace}LambdaFunction.Arn",
              id: "{namespace}RuleTarget"
            }]
          } # closes properties
        }
      }
    end

    it "cloudformation format" do
      # pp resource  # uncomment to see and debug
      # pp resource.logical_id # uncomment to see and debug
      # pp resource.attributes # uncomment to see and debug
      # pp resource.properties # uncomment to see and debug
      expect(resource.logical_id).to eq "SecurityJobCheckEventsRule"
      expect(resource.type).to eq "AWS::Events::Rule"
      properties = resource.properties
      expect(properties['State']).to eq "ENABLED"
      # properties under EventPattern has special dasherized and pascalized casing
      event_pattern = properties['EventPattern']
      expect(event_pattern.key?('detail-type')).to be true
      expect(event_pattern['detail']['eventSource']).to eq ["ec2.amazonaws.com"]
    end
  end

  context "medium form resource with no replacements" do
    let(:replacements) { {} }
    let(:definition) do
      [:rest_api,
       type: "AWS::ApiGateway::RestApi",
        properties: {
          name: "demo-test"
        }
      ]
    end

    it "cloudformation format" do
      # pp resource # uncomment to see and debug
      # pp resource.attributes # uncomment to see and debug
      # pp resource.properties # uncomment to see and debug
      expect(resource.logical_id).to eq "RestApi"
      expect(resource.type).to eq "AWS::ApiGateway::RestApi"
      properties = resource.properties
      expect(properties['Name']).to eq "demo-test"
    end
  end

  context "medium form resource with replacements" do
    let(:replacements) do
      { namespace: "SecurityJobCheck" }
    end
    let(:definition) do
      ["{namespace}EventsRule",
        type: "AWS::Events::Rule",
        properties: {
          event_pattern: {
            detail_type: ["AWS API Call via CloudTrail"],
            detail: {
              event_source: ["ec2.amazonaws.com"],
              event_name: [
                "AuthorizeSecurityGroupIngress",
              ]
            }
          },
          state: "ENABLED",
          targets: [{
            arn: "!GetAtt {namespace}LambdaFunction.Arn",
            id: "{namespace}RuleTarget"
          }]
        } # closes properties
      ]
    end

    it "cloudformation format" do
      # pp resource  # uncomment to see and debug
      # pp resource.logical_id # uncomment to see and debug
      # pp resource.attributes # uncomment to see and debug
      # pp resource.properties # uncomment to see and debug
      expect(resource.logical_id).to eq "SecurityJobCheckEventsRule"
      expect(resource.type).to eq "AWS::Events::Rule"
      properties = resource.properties
      expect(properties['State']).to eq "ENABLED"
      # properties under EventPattern has special dasherized and pascalized casing
      event_pattern = properties['EventPattern']
      expect(event_pattern.key?('detail-type')).to be true
      expect(event_pattern['detail']['eventSource']).to eq ["ec2.amazonaws.com"]
    end
  end

  context "short form resource with no replacements" do
    let(:replacements) { {} }
    let(:definition) do
      [:rest_api, "AWS::ApiGateway::RestApi", name: "demo-test" ]
    end

    it "cloudformation format" do
      # pp resource # uncomment to see and debug
      # pp resource.attributes # uncomment to see and debug
      # pp resource.properties # uncomment to see and debug
      expect(resource.logical_id).to eq "RestApi"
      expect(resource.type).to eq "AWS::ApiGateway::RestApi"
      properties = resource.properties
      expect(properties['Name']).to eq "demo-test"
    end
  end

end

