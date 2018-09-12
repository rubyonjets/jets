describe "Stack parameter" do
  let(:parameter) { Jets::Stack::Parameter.new(definition) }

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
      pp parameter.template
      # expect(parameter.template).to eq(
      #   ...
      # )
    end
  end

  context "medium form" do
    let(:definition) do
      [:company, default: "boltops"]
    end
    it "template" do
      pp parameter.template
      # expect(parameter.template).to eq(
      #   ...
      # )
    end
  end

  context "short form" do
    let(:definition) do
      [:ami_id, "ami-123"]
    end
    it "template" do
      pp parameter.template
      # expect(parameter.template).to eq(
      #   ...
      # )
    end
  end
end
