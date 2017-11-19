module Jets::Controller::Renderers
  autoload :AwsProxyRenderer, "jets/controller/renderers/aws_proxy_renderer"
  autoload :BaseRenderer, "jets/controller/renderers/base_renderer"
  autoload :FileRenderer, "jets/controller/renderers/file_renderer"
  autoload :JsonRenderer, "jets/controller/renderers/json_renderer"
  autoload :PlainRenderer, "jets/controller/renderers/plain_renderer"
  autoload :TemplateRenderer, "jets/controller/renderers/template_renderer"
end
