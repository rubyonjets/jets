class Jets::Controller
  DEFAULT_CONTENT_TYPE = "text/html; charset=utf-8"

  autoload :Base, "jets/controller/base"
  autoload :Callbacks, "jets/controller/callbacks"
  autoload :Cookies, "jets/controller/cookies"
  autoload :Layout, "jets/controller/layout"
  autoload :Middleware, "jets/controller/middleware"
  autoload :Params, "jets/controller/params"
  autoload :Rack, "jets/controller/rack"
  autoload :Redirection, "jets/controller/redirection"
  autoload :Renderers, "jets/controller/renderers"
  autoload :Rendering, "jets/controller/rendering"
  autoload :Request, "jets/controller/request"
  autoload :Response, "jets/controller/response"
end
