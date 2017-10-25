require "spec_helper"

describe Lam::Process::Infer do
  describe "lam" do
    let(:infer) { Lam::Process::Infer.new(handle) }

    context("controller") do
      let(:handle) { "handlers/controllers/posts.create" }
      it "should infer path and code" do
        expect(infer.controller[:path]).to include "app/controllers/posts_controller.rb"
        expect(infer.controller[:code]).to eq "PostsController.new(event, context).create"
      end
    end

    context("function") do
      let(:handle) { "handlers/functions/posts.create" }
      it "should infer path and code" do
        expect(infer.function[:path]).to include "app/functions/posts.rb"
        expect(infer.function[:code]).to eq "create(event, context)"
      end
    end

  end
end
