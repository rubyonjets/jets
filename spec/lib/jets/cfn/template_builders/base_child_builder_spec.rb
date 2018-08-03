describe Jets::Cfn::TemplateBuilders::BaseChildBuilder do
  let(:builder) do
    Jets::Cfn::TemplateBuilders::BaseChildBuilder.new(app_class)
  end
  let(:app_class) { PostsController }


  describe "BaseChildBuilder" do
    it "contains common others for classes inheriting BaseChildBuilder" do
      # does not yet have the compose method, it is expected to be implemented
      # by the classes inheriting BaseChildBuilder
      expect(builder).not_to respond_to(:compose)

      expect(builder).to respond_to(:template_path)
      expect(builder).to respond_to(:add_common_parameters)
      expect(builder).to respond_to(:add_functions)
      expect(builder).to respond_to(:add_function)
    end
  end
end
