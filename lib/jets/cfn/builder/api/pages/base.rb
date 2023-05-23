module Jets::Cfn::Builder::Api::Pages
  class Base
    class_attribute :pages
    @@pages = {}

    class << self
      extend Memoist

      # Returns: Array<Page>
      def pages
        return @@pages[self.name] if @@pages[self.name]

        pages = []
        uids_map = build_uids_map
        uids_map.each do |uid, existing_page|
          if existing_page
            pages[existing_page] ||= []
            pages[existing_page] << uid
          end
        end
        pages.compact! # not using page 0 so need to compact to remove the first nil element

        # Remove existing uids from uids_map. Leave behind new uids
        pages.each do |page|
          page.each do |i|
            uids_map.delete(i)
          end
        end

        # Fill up available space in each page so all existing pages are full
        keys = uids_map.keys
        pages.each do |page|
          break if keys.empty?
          while page.size < page_limit
            uid = keys.shift
            break if uid.nil?
            page << uid
          end
        end

        # Add remaining slices to new additional pages
        pages += keys.each_slice(page_limit).to_a

        @@pages[self.name] = []
        pages.each_with_index do |uids, i|
          # Note: page number starts at 1
          # Because of this we need to do a pages.compact! above to remove the first nil element. Feel this is easier for follow for us humans.
          @@pages[self.name] << Page.new(items: uids, number: i+1)
        end

        @@pages[self.name]
      end

      # Build map that has uids as keys and page number as value
      # For Resources, the uid is the path
      #   Example: {"a1"=>0, "a2"=>0, "b1"=>1, "b2"=>1, "c1"=>2, "c2"=>2}
      # For Methods, the uid is the method|path
      #   Example: {"GET|a1"=>0, "GET|a2"=>0, "GET|b1"=>1, "GET|b2"=>1, "GET|c1"=>2, "GET|c2"=>2}
      def build_uids_map
        map = {}
        # uids is interface method
        uids.each do |uid|
          map[uid] = find_page_index(uid)
        end
        map
      end

      def find_page_index(new_uid)
        slices = previously_deployed || []
        slices.each_with_index do |slice, page_number|
          items = slice["items"]
          items.find do |old_uid|
            return page_number if old_uid == new_uid # found
          end
        end
        nil # not found
      end

      def previously_deployed
        state = Jets::Router::State.new
        name = self.to_s.split('::').last.downcase
        deployed = state.load(name) # IE: state.load("resources") or state.load("methods")
        deployed
      end
      memoize :previously_deployed

      # Relevant CloudFormation limits:
      #    Resources 500
      #    Parameters 200
      #    Outputs 200
      # For API Gateway Methods template,
      # Lambda Functions and APIGW Resources are passed in as parameters.
      # Each APIGW Method can use 2 parameters.
      # So use page limit of 100 to provide a buffer.
      # Technically, can use a different limit for Resources and Cors templates,
      # but keeping all at 100 for consistency.
      #
      # JETS_API_PAGE_LIMIT is based on that
      # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-limits.html
      def page_limit
        Integer(ENV['JETS_API_PAGE_LIMIT'] || 100)
      end
    end
  end
end
