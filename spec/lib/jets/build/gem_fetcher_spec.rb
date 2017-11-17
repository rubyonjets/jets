require "spec_helper"

describe Jets::Build::GemFetcher do
  context "already downloaded" do
    let(:fetcher) do
      fetcher = Jets::Build::GemFetcher.new
      allow(fetcher).to receive(:exit) # stub out exit
      allow(fetcher).to receive(:compiled_gem_paths).and_return(compiled_gem_paths)
      allow(fetcher).to receive(:url_exists?).and_return(url_exists)
      fetcher
    end
    let(:url_exists) { true }

    context "all gems available" do
      it "downloads all gems" do
        allow(fetcher).to receive(:get_linux_gem)
        allow(fetcher).to receive(:get_linux_library)
        fetcher.run
      end
    end

    context "generally" do
      it "gem_name_from_path" do
        path = "/tmp/jets/demo/bundled/gems/ruby/2.4.0/extensions/x86_64-darwin-16/2.4.0-static/pg-0.21.0/pg_ext.bundle"
        gem_name = fetcher.gem_name_from_path(path)
        expect(gem_name).to eq "pg-0.21.0"

        path = "/tmp/jets/demo/bundled/gems/ruby/2.4.0/extensions/x86_64-darwin-16/2.4.0-static/mygem-0.1.0/subfolder/another-folder/pg_ext.bundle"
        gem_name = fetcher.gem_name_from_path(path)
        expect(gem_name).to eq "mygem-0.1.0"

        path = "/tmp/jets/demo/bundled/gems/ruby/2.4.0/extensions/x86_64-darwin-16/2.4.0-static/mygem-0.2.0/subfolder/another-folder/pg_ext.so"
        gem_name = fetcher.gem_name_from_path(path)
        expect(gem_name).to eq "mygem-0.2.0"
      end

      it "versionless_gem_name" do
        gem_name = "byebug-0.9.1"
        versionless_gem_name = fetcher.versionless_gem_name(gem_name)
        expect(versionless_gem_name).to eq "byebug"
      end
    end
  end

  def compiled_gem_paths
    %w[
      /tmp/jets/demo/bundled/gems/ruby/2.4.0/extensions/x86_64-darwin-16/2.4.0-static/nokogiri-1.8.1/nokogiri/nokogiri.so
      /tmp/jets/demo/bundled/gems/ruby/2.4.0/extensions/x86_64-darwin-16/2.4.0-static/pg-0.21.0/pg_ext.so
    ]
  end
end
