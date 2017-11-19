module Jets::RenderingHelper
  # ensure that we always add the controller view name. So when rendering
  # a partial:
  #   <%= render "mypartial" %>
  # gets turned into:
  #   <%= render "articles/mypartial" %>
  def render(options = {}, locals = {}, &block)
    if options.is_a?(String) && !options.include?('/')
      folder = _get_containing_folder(caller[0])
      partial_name = options # happens to be the partial name
      partial_name = "#{folder}/#{partial_name}"
      options = partial_name
    end

    super(options, locals, &block)
  end

  # Ugly, going back up the caller stack to find out what view path
  # we are in
  def _get_containing_folder(caller_line)
    text = caller_line.split(':').first
    # .../fixtures/apps/demo/app/views/posts/index.html.erb
    text.split('/')[-2] # posts
  end
end
ActionView::Helpers.send(:include, Jets::RenderingHelper)
