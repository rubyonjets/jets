describe Jets::Commands::Console do
    let(:build) do
      Jets::Commands::Console.new(provided_environment_name)
    end
  
    describe "Console" do
      context 'with environment' do
        let(:provided_environment_name) { "sandbox" }
        it "accepts environment" do
            expect(build.environment).to eq provided_environment_name
        end
      end

      context "no environment" do
        let(:provided_environment_name) { nil }
        it 'defaults to development' do
            expect(build.environment).to eq nil
        end
      end
    end
end
