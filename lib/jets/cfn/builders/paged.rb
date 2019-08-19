module Jets::Cfn::Builders
  module Paged
    def current_page_number
      return @current_page_number ||= 0
    end

    def pages
      return @pages if @pages
      @current_page_number = -1
      @pages = []
    end

    def push(template)
      pages.push(template)
      @current_page_number = pages.length - 1
      current_page
    end

    def first_page
      @current_page_number = 0
      current_page
    end

    def range
      (0..(pages.length-1))
    end

    def turn_to_page(index)
      @current_page_number = index
      current_page
    end

    def current_page
      pages[@current_page_number]
    end
  end
end
