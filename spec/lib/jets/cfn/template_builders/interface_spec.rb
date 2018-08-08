class InterfaceTest
  include Jets::Cfn::TemplateBuilders::Interface
end

describe Jets::Cfn::TemplateBuilders::Interface do
  let(:interface) do
    InterfaceTest.new
  end

  describe "Interface" do
    # Nice to see a summary of methods here
    it "defines method that are common to all template builders" do
      # does not yet have the compose method, it is expected to be implemented
      # by the classes inheriting Interface
      expect(interface).to respond_to(:build)
      expect(interface).to respond_to(:write)
      expect(interface).to respond_to(:template)
      expect(interface).to respond_to(:text)
      expect(interface).to respond_to(:add_resource)
      expect(interface).to respond_to(:add_parameter)
      expect(interface).to respond_to(:add_output)
    end
  end
end
