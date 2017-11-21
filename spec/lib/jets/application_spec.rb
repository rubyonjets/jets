require "spec_helper"

describe Jets::Application do
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

  context "app.config loaded with defaults" do
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
      expect(config.function).to be_a(RecursiveOpenStruct)
      expect(config.function.timeout).to eq 10
      expect(config.function.memory_size).to eq 1536
    end
  end
end

