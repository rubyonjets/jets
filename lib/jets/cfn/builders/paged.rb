module Jets::Cfn::Builders
  module Paged
    @current_page = 0   
    
    @pages = Array[]

    def push(template)
      @pages.push(template)
      @current_page += 1
      current_page
    end

    def first_page
      @current_page = 0
      current_page
    end

    def range
      (0..(@pages.length-1))
    end

    def turn_to_page(index)
      @current_page = index
      current_page
    end

    def current_page
      @pages[@current_page]
    end
  end
end
