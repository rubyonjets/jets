module Jets::SpecHelpers
  module Fixtures
    def fixture_path(filename)
      "#{Jets.root}/spec/fixtures/#{filename}"
    end

    def fixture_file(filename)
      File.new(fixture_path(filename))
    end
  end
end
