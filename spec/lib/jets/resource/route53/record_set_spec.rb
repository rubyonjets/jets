describe Jets::Resource::Route53::RecordSet do

  context 'default' do
    let(:record_set) do
      Jets::Resource::Route53::RecordSet.new
    end

    it "record_set" do
      allow(Jets.config.domain).to receive(:name).and_return("demo-test.example.com")
      allow(Jets.config.domain).to receive(:hosted_zone_name).and_return("example.com")
      allow(Jets::Resource::ApiGateway::RestApi).to receive(:internal_logical_id).and_return("fakerestapi")

      expect(record_set.logical_id).to eq "DnsRecord"
      properties = record_set.properties
      # pp properties # uncomment to debug
      expect(properties["HostedZoneName"]).to eq "example.com."
      expect(properties["Comment"]).to eq "DNS record managed by Jets"
      expect(properties["Name"]).to eq "demo-test.example.com"
      expect(properties["Type"]).to eq "CNAME"
      expect(properties["TTL"]).to eq "60" # special casing
      expect(properties["ResourceRecords"]).to eq ["!GetAtt DomainName.RegionalDomainName"]
    end
  end

end
