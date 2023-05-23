# frozen_string_literal: true

describe Jets::Cfn::Template do
  let(:path) { '/tmp/test.txt' }
  let(:template) do
    described_class.new(path, s3_bucket: s3_bucket)
  end

  context 'without s3_bucket' do
    let(:s3_bucket) { nil }
    let(:body) { 'long file body' }

    it 'should read file from disk' do
      expect(template).to receive(:body).and_return(body)
      expect(template.send(:from_path)[:template_body]).to eq body
    end
  end

  context 'with s3_bucket' do
    let(:s3_bucket) { 'test' }
    let(:url) { "https://s3.amazonaws.com/#{s3_bucket}/test" }

    it 'should upload file to s3' do
      expect(template).to receive(:upload_file_to_s3).and_return(url)
      expect(template.send(:from_s3)[:template_url]).to eq url
    end
  end
end
