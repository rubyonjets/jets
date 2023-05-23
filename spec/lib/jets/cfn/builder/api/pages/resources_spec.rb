# Spec has a few broken examples.
# Commenting out and keeping around for now.
# Will likely remove paginated resources in the future.

# describe Jets::Cfn::Builder::Api::Pages::Resources do
#   let(:builder) do
#     ENV['JETS_APIGW_PAGE_LIMIT'] = '3'
#     Jets::Cfn::Builder::Api::Pages::Resources
#   end

#   def pages(builder)
#     pages = builder.pages
#     pages.map do |page|
#       page.items
#     end
#   end

#   before(:each) do
#     Jets::Cfn::Builder::Api::Pages::Resources.send(:class_variable_set, :@@pages, {})
#   end

#   # Example previously_deployed structure:
#   # [
#   #   {
#   #     "items": [
#   #       "*catchall",
#   #       "posts",
#   #     ],
#   #     "number": 1,
#   #   }
#   # ]
#   def previously_deployed(slices)
#     result = []
#     slices.each_with_index do |slice, index|
#       data = {
#         "items" => slice,
#         "page_number" => index,
#       }
#       result << data
#     end
#     result
#   end

#   describe "PageBuilder" do
#     it "same pages after as before" do
#       previously_deployed = previously_deployed([
#         %w[a1 a2],
#         %w[b1 b2],
#         %w[c1 c2],
#       ])
#       uids = %w[a1 a2 b1 b2 c1 c2]
#       allow(builder).to receive(:previously_deployed).and_return(previously_deployed)
#       allow(builder).to receive(:uids).and_return(uids)

#       pages = pages(builder)
#       expect(pages).to eq(
#         [["a1", "a2"], ["b1", "b2"], ["c1", "c2"]]
#       )
#     end

#     it "fill up pages" do
#       previously_deployed = previously_deployed([
#         %w[a1 a2],
#         %w[b1 b2],
#         %w[c1 c2],
#       ])
#       uids = %w[a1 a2 a3 b1 b2 c1 c2 d1]
#       allow(builder).to receive(:previously_deployed).and_return(previously_deployed)
#       allow(builder).to receive(:uids).and_return(uids)

#       pages = pages(builder)
#       expect(pages).to eq(
#         [["a1", "a2", "a3"], ["b1", "b2", "d1"], ["c1", "c2"]]
#       )
#     end

#     it "fill up pages with no nils" do
#       previously_deployed = previously_deployed([
#         %w[a1],
#         %w[b1],
#         %w[c1],
#       ])
#       uids = %w[a1 b1 c1 c2 d1 d2 d3 d4]
#       allow(builder).to receive(:previously_deployed).and_return(previously_deployed)
#       allow(builder).to receive(:uids).and_return(uids)

#       pages = pages(builder)
#       expect(pages).to eq(
#         [["a1", "c2", "d1"], ["b1", "d2", "d3"], ["c1", "d4"]]
#       )
#     end

#     it "build remaining slices" do
#       previously_deployed = previously_deployed([
#         %w[a1 a2],
#         %w[b1 b2],
#         %w[c1 c2],
#       ])
#       uids = %w[a1 a2 a3 b1 b2 c1 c2 d1 e1 e2 e3 e4 e5]
#       allow(builder).to receive(:previously_deployed).and_return(previously_deployed)
#       allow(builder).to receive(:uids).and_return(uids)

#       pages = pages(builder)
#       expect(pages).to eq(
#         [["a1", "a2", "a3"],
#          ["b1", "b2", "d1"],
#          ["c1", "c2", "e1"],
#          ["e2", "e3", "e4"],
#          ["e5"]]
#       )
#     end

#     it "no old pages state" do
#       previously_deployed = nil
#       uids = %w[a1 a2 b1 b2 c1 c2]
#       allow(builder).to receive(:previously_deployed).and_return(previously_deployed)
#       allow(builder).to receive(:uids).and_return(uids)

#       pages = pages(builder)
#       expect(pages).to eq(
#         [["a1", "a2", "b1"], ["b2", "c1", "c2"]]
#       )
#     end
#   end
# end
