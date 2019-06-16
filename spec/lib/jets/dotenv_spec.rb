describe Jets::Dotenv do
  describe "#load!" do
    it "replaces ssm:<relative-path> with SSM parameters prefixed with /<app-name>/<jets-env>/" do
      relative_path = "authenticated-url"
      value = "https://foo:bar@example.com"

      expect(::Dotenv).to receive(:load).and_return(
        "AUTENTICATED_URL" => "ssm:#{relative_path}",
      )

      username_response_double = double(
        Aws::SSM::Types::GetParameterResult,
        parameter: Aws::SSM::Types::Parameter.new(value: value),
      )
      expect_any_instance_of(Aws::SSM::Client).to receive(:get_parameter)
        .with(name: "/demo/test/#{relative_path}", with_decryption: true)
        .and_return(username_response_double)

      env = Jets::Dotenv.new.load!

      expect(env.fetch("AUTENTICATED_URL")).to eq value
      expect(ENV.fetch("AUTENTICATED_URL")).to eq value
    end

    it "replaces ssm:/<absolute-path> with SSM parameters from the provided path" do
      absolute_path = "/absolute/path"
      value = "foo-bar"

      expect(::Dotenv).to receive(:load).and_return(
        "ABSOLUTE_VARIABLE" => "ssm:#{absolute_path}",
      )

      absolute_response_double = double(
        Aws::SSM::Types::GetParameterResult,
        parameter: Aws::SSM::Types::Parameter.new(value: value),
      )
      expect_any_instance_of(Aws::SSM::Client).to receive(:get_parameter)
        .with(name: absolute_path, with_decryption: true)
        .and_return(absolute_response_double)


      env = Jets::Dotenv.new.load!

      expect(env.fetch("ABSOLUTE_VARIABLE")).to eq value
      expect(ENV.fetch("ABSOLUTE_VARIABLE")).to eq value
    end

    it "aborts the process with a helpful error if an SSM parameter is not found at AWS" do
      expect(::Dotenv).to receive(:load).and_return(
        "ABSOLUTE_VARIABLE" => "ssm:/absolute/path",
      )

      expect_any_instance_of(Aws::SSM::Client).to receive(:get_parameter)
        .and_raise(Aws::SSM::Errors::ParameterNotFound.new(Seahorse::Client::RequestContext.new, ""))

      expect { Jets::Dotenv.new.load! }
        .to raise_error(SystemExit)
        .and output(/No parameter matching \/absolute\/path found/).to_stderr
    end
  end
end
