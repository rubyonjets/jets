describe "Stack Depends" do
  before(:each) { Alert ; Custom }
  let(:depends) { Jets::Stack::Depends.new(depends_on) }

  context "single item" do
    context "no class prefix" do
      let(:depends_on) do
        [Jets::Stack::Depends::Item.new(:alert)]
      end
      it "params" do
        # pp depends.params # uncomment to debug
        expect(depends.params).to eq({"Delivered"=>"!GetAtt Alert.Outputs.Delivered"})
      end
    end

    context "class prefix" do
      let(:depends_on) do
        [Jets::Stack::Depends::Item.new(:alert, class_prefix: true)]
      end
      it "params has prefix added to the key but not the value" do
        # pp depends.params # uncomment to debug
        expect(depends.params).to eq({"AlertDelivered"=>"!GetAtt Alert.Outputs.Delivered"})
      end
    end
  end

  context "multiple items" do
    context "no class prefix" do
      let(:depends_on) do
        [
          Jets::Stack::Depends::Item.new(:alert),
          Jets::Stack::Depends::Item.new(:custom),
        ]
      end
      it "params" do
        # pp depends.params # uncomment to debug
        expect(depends.params).to eq({"Delivered"=>"!GetAtt Alert.Outputs.Delivered", "Test"=>"!GetAtt Custom.Outputs.Test"})
      end
    end
  end
end
