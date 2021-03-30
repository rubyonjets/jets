describe Jets::Application do
  context "Jets::Application.instance" do
    let(:app) do
      Jets::Application.instance
    end

    describe "configure" do
      it "should assign config values" do
        app.configure do
          config.test1 = "value1"
          config.test2 = "value2"
        end
        h = app.config.to_hash
        expect(h[:test1]).to eq("value1")
        expect(h[:test2]).to eq("value2")
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
      expect(config.function.timeout).to eq 30
      expect(config.function.memory_size).to eq 1536
    end

    it "should have a default time zone defined" do
      expect(config.time_zone).to eq "UTC"
      expect(Time.zone).to eq Time.find_zone!("UTC")
    end

    it "routes should be loaded" do
      router = app.routes
      expect(router).to be_a(Jets::Router)
      expect(router.routes).not_to be_empty
    end

    it "Rails constant should not be defined" do
      expect { Rails }.to raise_error(NameError)
    end

    it "sets iam_policy by concatenating default_iam_policy" do
      app.configure do
        config.default_iam_policy = [{ effect: 'Fly', resource: "arn:aws:bird:::*" }]
        config.iam_policy = [{ effect: 'Fire', resource: "arn:aws:gun:::*" }]
        set_iam_policy
      end
      expect(config.iam_policy).to eql([
                                         { effect: 'Fly', resource: "arn:aws:bird:::*" },
                                         { effect: 'Fire', resource: "arn:aws:gun:::*" }
                                       ])
    end

    it "sets iam_policy to app.class.default_iam_policy when iam_policy and default_iam_policy are unset" do
      app.configure do
        config.default_iam_policy = nil
        config.iam_policy = nil
        set_iam_policy
      end
      expect(config.iam_policy).to eql(app.class.default_iam_policy)
    end

    it "sets iam_policy to empty when iam_policy and default_iam_policy are empty" do
      app.configure do
        config.default_iam_policy = []
        config.iam_policy = []
        set_iam_policy
      end
      expect(config.iam_policy).to eql([])
    end
  end

  context "database configurations" do
    let(:app) { Jets::Application.instance }

    it "standard single database config" do
      configurations = app.load_db_config("spec/fixtures/db_configs/database.single.yml")
      hash_config = configurations.configs_for(env_name: Jets.env).first # the test environment
      config = hash_config.config
      expect(config["adapter"]).to eq "mysql2"
    end

    it "standard multiple database config" do
      configurations = app.load_db_config("spec/fixtures/db_configs/database.multi.yml")
      hash_configs = configurations.configs_for(env_name: Jets.env, include_replicas: true)
      spec_names = hash_configs.map { |h| h.spec_name }
      expect(spec_names).to eq ["primary", "primary_replica", "animals", "animals_replica"]
    end
  end

  context "custom initializers" do
    it "should load in order" do
      expect(JETS_TEST_INITIALIZER_ONE_TIME).to be < JETS_TEST_INITIALIZER_TWO_TIME
    end
  end
end
