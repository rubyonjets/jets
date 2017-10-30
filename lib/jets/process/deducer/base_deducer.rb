class Jets::Process::Deducer::BaseDeducer
  def initialize(handler)
    @handler = handler # handlers/controllers/posts.create
    @handler_path, @handler_method = @handler.split('.')
    # @handler_path = "handlers/controllers/posts"
    # @handler_path = "create"
  end
end