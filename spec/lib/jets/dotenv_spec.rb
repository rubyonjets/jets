describe Jets::Dotenv do
  describe "#load!" do
    it "replaces ${ssm:<relative-path>} with SSM parameters prefixed with /<app-name>/<jets-env>/" do
      expect(::Dotenv).to receive(:load).and_return(
        "AUTENTICATED_URL" => "https://${ssm:username}:${ssm:password}@host.com",
      )

      username_response_double = double(
        Aws::SSM::Types::GetParameterResult,
        parameter: Aws::SSM::Types::Parameter.new(value: "my-user"),
      )
      expect_any_instance_of(Aws::SSM::Client).to receive(:get_parameter)
        .with(name: "/demo/test/username", with_decryption: true)
        .and_return(username_response_double)

      password_response_double = double(
        Aws::SSM::Types::GetParameterResult,
        parameter: Aws::SSM::Types::Parameter.new(value: "my-password"),
      )
      expect_any_instance_of(Aws::SSM::Client).to receive(:get_parameter)
        .with(name: "/demo/test/password", with_decryption: true)
        .and_return(password_response_double)

      env = Jets::Dotenv.new.load!

      expect(env.fetch("AUTENTICATED_URL")).to eq "https://my-user:my-password@host.com"
      expect(ENV.fetch("AUTENTICATED_URL")).to eq "https://my-user:my-password@host.com"
    end

    it "replaces ${ssm:/<absolute-path>} with SSM parameters from the provided path" do
      expect(::Dotenv).to receive(:load).and_return(
        "ABSOLUTE_VARIABLE" => "${ssm:/absolute/path}",
      )

      absolute_response_double = double(
        Aws::SSM::Types::GetParameterResult,
        parameter: Aws::SSM::Types::Parameter.new(value: "my-absolute-value"),
      )
      expect_any_instance_of(Aws::SSM::Client).to receive(:get_parameter)
        .with(name: "/absolute/path", with_decryption: true)
        .and_return(absolute_response_double)


      env = Jets::Dotenv.new.load!

      expect(env.fetch("ABSOLUTE_VARIABLE")).to eq "my-absolute-value"
      expect(ENV.fetch("ABSOLUTE_VARIABLE")).to eq "my-absolute-value"
    end

    it "aborts the process with a helpful error if an SSM parameter is not found at AWS" do
      expect(::Dotenv).to receive(:load).and_return(
        "ABSOLUTE_VARIABLE" => "${ssm:/absolute/path}",
      )

      expect_any_instance_of(Aws::SSM::Client).to receive(:get_parameter)
        .and_raise(Aws::SSM::Errors::ParameterNotFound.new(Seahorse::Client::RequestContext.new, ""))

      expect { Jets::Dotenv.new.load! }
        .to raise_error(SystemExit)
        .and output(/No parameter matching \/absolute\/path found/).to_stderr
    end
  end
end
