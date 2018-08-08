describe Jets::Application do
  context "Jets::Application.new" do
    let(:app) do
      Jets::Application.new
    end

    describe "configure" do
      it "should assign config values" do
        app.configure do
          config.test1 = "value1"
          config.test2 = "value2"
        end
        expect(app.config.to_hash).to eq(
          test1: "value1",
          test2: "value2",
        )
      end
    end
  end

  context "Jets.application loaded with defaults" do
    let(:app) { Jets.application }
    let(:config) { app.config }

    it "should assign function properties" do
      properties = { dead_letter_queue: { target_arn: "arn" } }
      app.configure do
        config.function.properties = properties
      end
      # pp config.function.properties.to_h
      expect(config.function.properties.to_h).to eq properties
    end

    it "should have defaults" do
      expect(config.function).to be_a(ActiveSupport::OrderedOptions)
      expect(config.function.timeout).to eq 10
      expect(config.function.memory_size).to eq 3008
    end

    it "routes should be loaded" do
      router = app.routes
      expect(router).to be_a(Jets::Router)
      expect(router.routes).not_to be_empty
    end
  end

end

