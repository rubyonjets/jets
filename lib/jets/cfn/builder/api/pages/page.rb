module Jets::Cfn::Builder::Api::Pages
  # Note: Do not use, it behaves differently in Ruby 2 v Ruby 3
  # Page = Struct.new(:items, :number)
  #
  # In Ruby 2, assigning an Array to items creates an extra :items key in the structure
  #
  #    #<struct Page items={:items=>["*catchall", "posts"],
  #
  # In Ruby 3, assigning an Array to items.
  #
  #    #<struct Page items=["*catchall", "posts"], number=1>
  #
  class Page
    attr_accessor :items, :number
    def initialize(items:, number:)
      @items, @number = items, number
    end
  end
end
