describe "Stack output" do
  let(:output) { Jets::Stack::Output.new("ExampleStack", definition) }

  context "long form" do
    let(:definition) do
      {
        vpc_id: {
          description: "vpc id",
          value: "!Ref VpcId",
        }
      }
    end
    it "template" do
      expect(output.template).to eq(
        {"VpcId"=>{"Description"=>"vpc id", "Value"=>"!Ref VpcId"}}
      )
    end
  end

  context "medium form" do
    let(:definition) do
      [:stack_name, value: "!Ref AWS::StackName"]
    end
    it "template" do
      expect(output.template).to eq(
        {"StackName"=>{"Value"=>"!Ref AWS::StackName"}}
      )
    end
  end

  context "short form with value" do
    let(:definition) do
      [:elb, "!Ref Elb"]
    end
    it "template" do
      expect(output.template).to eq(
        {"Elb"=>{"Value"=>"!Ref Elb"}}
      )
    end
  end

  context "short form without value" do
    let(:definition) do
      [:elb]
    end
    it "template" do
      expect(output.template).to eq(
        {"Elb"=>{"Value"=>"!Ref Elb"}}
      )
    end
  end
end
