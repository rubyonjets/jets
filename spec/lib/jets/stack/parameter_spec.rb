describe "Stack parameter" do
  let(:parameter) { Jets::Stack::Parameter.new("ExampleStack", definition) }

  context "long form" do
    let(:definition) do
      {
        instance_type: {
          default: "t2.micro" ,
          description: "instance type" ,
        }
      }
    end
    it "template" do
      expect(parameter.template).to eq(
        {"InstanceType"=>{"Default"=>"t2.micro", "Description"=>"instance type", "Type"=>"String"}}
      )
    end
  end

  context "medium form" do
    let(:definition) do
      [:company, default: "boltops"]
    end
    it "template" do
      expect(parameter.template).to eq(
        {"Company"=>{"Default"=>"boltops", "Type"=>"String"}}
      )
    end
  end

  context "short form default value" do
    let(:definition) do
      [:ami_id, "ami-123"]
    end
    it "template" do
      expect(parameter.template).to eq(
        {"AmiId"=>{"Default"=>"ami-123", "Type"=>"String"}}
      )
    end
  end

  context "short form no default value" do
    let(:definition) do
      [:ami_id]
    end
    it "template" do
      expect(parameter.template).to eq(
        {"AmiId" => {"Type"=>"String"}}
      )
    end
  end
end
