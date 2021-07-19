require "active_support/number_helper"

describe Jets::Builders::Md5Zip do
  include ActiveSupport::NumberHelper

  let(:instance) { described_class.new(folder) }
  let(:folder) { 'test-folder' }

  describe 'initialize' do
    it { expect(instance.instance_variable_get(:@path)).to eq("#{Jets.build_root}/#{folder}") }
  end

  describe '#number_to_human_size' do
    it 'converts file size to human readable number' do
      file_size = 25000
      expect(instance.send(:number_to_human_size, file_size)).to eq(number_to_human_size(file_size))
    end
  end
end