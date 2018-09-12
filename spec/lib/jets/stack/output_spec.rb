describe "Stack output" do
  let(:output) { Jets::Stack::Output.new(definition) }

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
        {"Default"=>"t2.micro", "Description"=>"instance type", "Type"=>"String"}
      )
    end
  end

  context "medium form" do
    let(:definition) do
      [:company, default: "boltops"]
    end
    it "template" do
      expect(parameter.template).to eq(
        {"Default"=>"boltops", "Type"=>"String"}
      )
    end
  end

  context "short form" do
    let(:definition) do
      [:ami_id, "ami-123"]
    end
    it "template" do
      expect(parameter.template).to eq(
        {"Default"=>"ami-123", "Type"=>"String"}
      )
    end
  end
end
