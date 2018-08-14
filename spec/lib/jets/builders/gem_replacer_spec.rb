describe "GemReplacer" do
  describe "checks" do
    # https://gems.lambdagems.com/gems/2.5.0/byebug/byebug-10.0.0-x86_64-linux.tgz
    it "checks if gems are available" do
      replacer = Jets::Builders::GemReplacer.new(Jets::Builders::CodeBuilder::JETS_RUBY_VERSION, {})
      puts replacer.missing_gems_message


      # gem_names = ["nokogiri-1.8.4", "pg-0.21.0"]
      # checks = Jets.config.lambdagems.sources.map do |source|
      #   exist = Lambdagem::Exist.new(lambdagems_url: source)
      #   exist.check(gem_names)
      # end
      # pp checks
      # gem_exists = checks.include?(true)
      # pp gem_exists
  end
  end
end
