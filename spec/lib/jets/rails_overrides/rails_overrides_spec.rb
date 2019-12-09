require "jets/overrides/rails"

class FakeView
  include Jets::RenderingHelper
end

describe "Rails Overrides" do
  let(:view) do
    FakeView.new
  end

  it "get_controller_name" do
    caller_lines = [
      "/home/ec2-user/.rbenv/versions/2.5.6/lib/ruby/gems/2.5.0/gems/haml-5.1.2/lib/haml/helpers/action_view_mods.rb:13:in `render'",
      "/Users/tung/src/tongueroo/jets/spec/fixtures/apps/demo/app/views/posts/index.html.erb:3:in `___sers_tung_src_tongueroo_jets_spec_fixtures_apps_demo_app_views_posts_index_html_erb__1209297671030770324_70251796312860'
    "]
    folder = view._get_containing_folder(caller_lines)
    expect(folder).to eq "posts"
  end
end
