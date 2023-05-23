module Jets::Router
  class Scope
    include Util

    module Macros
      OPTION_ACCESSORS = Set.new
      extend ActiveSupport::Concern

      class_methods do
        def option_accessor(*names)
          names.each do |name|
            define_method(name) do
              @options[name]
            end
            define_method("#{name}=") do |value|
              if value.nil?
                @options.delete(name)
              else
                @options[name] = value
              end
            end
            define_method("#{name}?") do
              !!@options[name]
            end
            OPTION_ACCESSORS.add(name)
          end
        end
      end

      # Allow [] and []= notation. Though Jets does not use this internally.
      # This is what Rails ActionDispatch::Routing::Mapper::Scope does.
      # Helps with compatibility in case plugins use this notation.
      def [](key)
        if OPTION_ACCESSORS.include?(key)
          send(key)
        else
          raise NoMethodError, "undefined method `#{key}' for #{self}"
        end
      end

      def []=(key, value)
        if OPTION_ACCESSORS.include?(key)
          send("#{key}=", value)
        else
          raise NoMethodError, "undefined method `#{key}' for #{self}"
        end
      end
    end
    include Macros

    attr_reader :options, :parent, :level, :children
    attr_accessor :next
    option_accessor :from, :path, :as, :resource_name, :module, :singular_resource,
      :controller, :defaults, :constraints, :shallow
    def initialize(options = {}, parent = nil, level = 1)
      @options = options
      @parent = parent
      @level = level
      @children = []
      if parent
        parent.children << self
      end
    end

    def new(options={})
      self.class.new(options, self, level + 1)
    end

    def virtual_controller
      case from
      when :member, :collection
        parent.virtual_controller
      when :resource
        controller || resource_name.to_s.pluralize
      else
        controller || resource_name
      end
    end

    def resolved_defaults
      result = {}
      from_top.each do |scope|
        result.merge!(scope.defaults) if scope.defaults
      end
      result
    end

    def resolved_constraints
      from_bottom.each do |scope|
        return scope.constraints if scope.constraints
      end
      nil
    end

    def resolved_module
      items = from_top.map(&:module).compact
      items.join('/') unless items.empty?
    end

    def needs_controller_path?
      return false if resource_name  # no adjustments if within resource or resources scope

      from.nil?
    end

    def virtual?
      from == :member || from == :collection
    end

    def resolved_path
      case from
      when :resource, :resources
        path || resource_name
      when :namespace, :path, nil
        path
      when :member, :collection
        parent.resolved_path
      end
    end

    def parent_or_higher?(other_scope)
      current_scope = self

      while current_scope.parent && !current_scope.parent.virtual?
        return true if current_scope.parent == other_scope
        current_scope = current_scope.parent
      end

      false
    end

    def real_parent?(scope)
      if scope.virtual?
        scope.parent == parent
      else
        parent == scope
      end
    end

    def resource_descendent?(scope=self)
      # return false
      scope.children.each do |child|
        return true if child.from == :resource || child.from == :resources
        return true if resource_descendent?(child)
      end
      false
    end

    def resource_sibling?
      return false
      !resource_siblings.empty?
    end

    def colliding_resource_sibling?
      return false
      # Don't think need to check for path because it doesn't really make sense
      # to point 2 different resources to the same path.
      resource_names = resource_siblings.map(&:resource_name)
      resource_names.uniq.size != resource_names.size
    end

    def resource_siblings
      return [] unless parent
      parent.children.select do |c|
        c != self &&
        (c.from == :resource || c.from == :resources)
      end
    end

    # At time of each_resource DSL evaluation, the routes file has not fully evaluated
    # and the scope context is not fully available. IE: info on the children.
    #
    # Placeholder param allows the values to lazily replaced later with full context.
    # We only have to replace the last segment with the placeholder.
    # This is because previous segments are already replaced with Route::Path#path_prefixes
    # scopes_from_top logic.
    def param_placeholder
      if resource_name
        "#{resource_name.upcase}_PARAM"
      else
        prefix = path.to_s.gsub('/','_').upcase
        "#{prefix}_PARAM"
      end
    end

    def from_top
      from_bottom.reverse
    end
    alias all_scopes from_top

    def from_bottom
      current_scope = self
      scopes = []
      previous_scope = nil # child
      # do not include the root scope
      while current_scope.parent
        current_scope.next = previous_scope if previous_scope
        scopes << current_scope
        previous_scope = current_scope
        current_scope = current_scope.parent
      end
      scopes
    end

    def any_parent_shallow?
      from_bottom.any? do |scope|
        scope.shallow? || scope.from == :shallow
      end
    end

    # singularize all except last item
    def singularize_leading(items)
      result = []
      items.each_with_index do |item, index|
        item = item.to_s
        r = index == items.size - 1 ? item : item.singularize
        result << r
      end
      result
    end

    def root?
      @parent.nil?
    end

    def to_s
      "<Scope:#{object_id} @level=#{@level} @options=#{@options}>"
    end
  end
end
