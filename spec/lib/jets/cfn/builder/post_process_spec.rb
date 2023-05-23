describe Jets::Cfn::Builder::PostProcess do
  context "one line" do
    let(:builder) do
      Jets::Cfn::Builder::PostProcess.new(text)
    end
    let(:text) do
      <<~EOL
      Resources:
        ApiMethods1:
        Properties:
          Parameters:
            IndexLambdaFunction: "!GetAtt PostsController.Outputs.IndexLambdaFunction"
      EOL
    end

    it "process" do
      text = builder.process
      expect(text).to eq <<~EOL
      Resources:
        ApiMethods1:
        Properties:
          Parameters:
            IndexLambdaFunction: !GetAtt PostsController.Outputs.IndexLambdaFunction
      EOL
    end
  end
end
