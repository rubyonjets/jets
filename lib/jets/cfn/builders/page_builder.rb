module Jets::Cfn::Builders
  class PageBuilder
    extend Memoist
    cattr_reader :pages

    # Build page slices
    def build
      map = build_map
      pages = []
      map.each do |path, existing_page|
        if existing_page
          pages[existing_page] ||= []
          pages[existing_page] << path
        end
      end

      # Remove existing paths from map. Leave behind new paths
      pages.each do |page|
        page.each do |i|
          map.delete(i)
        end
      end

      # Fill up available space in each page so all existing pages are full
      keys = map.keys
      pages.each do |page|
        break if keys.empty?
        while page.size < page_limit
          path = keys.shift
          break if path.nil?
          page << path
        end
      end

      # Add remaining slices to new additional pages
      pages += keys.each_slice(page_limit).to_a

      @@pages = pages

      pages
    end

    # Build map that has paths as keys and page number as value
    # Example: {"a1"=>0, "a2"=>0, "b1"=>1, "b2"=>1, "c1"=>2, "c2"=>2}
    def build_map
      map = {}
      new_paths.each do |path|
         map[path] = find_page_index(path)
      end
      map
    end

    def find_page_index(new_path)
      pages = old_pages || []
      pages.each_with_index do |slice, i|
        slice.find do |old_path|
          return i if old_path == new_path
        end
      end
      nil
    end

    def old_pages
      state = Jets::Router::State.new
      state.load("pages")
    end
    memoize :old_pages

    def new_paths
      Jets::Router.all_paths.reject { |p| p == '' }
    end

    # Relevant is CloudFormation Outputs limit is 200
    # JETS_APIGW_PAGE_LIMIT is based on that
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-limits.html
    def page_limit
      Integer(ENV['JETS_APIGW_PAGE_LIMIT'] || 200)
    end
  end
end
