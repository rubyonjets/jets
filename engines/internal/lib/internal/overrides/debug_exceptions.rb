# These overrides allows DebugExceptions middleware to work with Jets.

# Straight override the initialize method to customize the template paths and
# include additiional jets rescue templates when needed.
# Note: With the way the ActionDispatch::DebugView class is written, we cannot
# use super to call the original initialize method.  Got to override the whole
# method.
ActionDispatch::DebugView.class_eval do
  def initialize(assigns)
    jets_templates = File.expand_path("../templates", __dir__)
    paths = [jets_templates, ActionDispatch::DebugView::RESCUES_TEMPLATE_PATH]
    lookup_context = ActionView::LookupContext.new(paths)
    super(lookup_context, assigns, nil)
  end
end

# Override source_fragment to use Jets.root instead of Rails.root
ActionDispatch::ExceptionWrapper.class_eval do
private
  def source_fragment(path, line)
    # Jets.root was Rails.root
    return unless Jets.respond_to?(:root) && Jets.root
    full_path = Jets.root.join(path)
    if File.exist?(full_path)
      File.open(full_path, "r") do |file|
        start = [line - 3, 0].max
        lines = file.each_line.drop(start).take(6)
        Hash[*(start + 1..(lines.count + start)).zip(lines).flatten]
      end
    end
  end
end

load "action_dispatch/middleware/debug_exceptions.rb"

ActionView::Helpers::SanitizeHelper::ClassMethods.module_eval do
  def sanitizer_vendor
    Jets::Html::Sanitizer # was Rails::Html::Sanitizer
  end
end
