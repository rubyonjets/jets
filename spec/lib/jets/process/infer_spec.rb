require "spec_helper"

describe Jets::Process::ProcessorDeducer do
  describe "ProcessorDeducer" do
    let(:deducer) { Jets::Process::ProcessorDeducer.new(handle) }

    context("controller") do
      let(:handle) { "handlers/controllers/posts.create" }
      it "deduces processor info" do
        expect(deducer.controller[:path]).to include "app/controllers/posts_controller.rb"
        expect(deducer.controller[:code]).to eq "PostsController.new(event, context).create"
      end
    end

    context("function") do
      let(:handle) { "handlers/functions/posts.create" }
      it "deduces processor info" do
        expect(deducer.function[:path]).to include "app/functions/posts.rb"
        expect(deducer.function[:code]).to eq "create(event, context)"
      end
    end

  end
end
