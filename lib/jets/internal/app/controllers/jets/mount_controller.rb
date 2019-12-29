# routes mount support
class Jets::MountController < Jets::BareController
  def call
    route = find_route
    # On Lambda, the route should always be found so this check on lambda is not needed.
    # But this is useful when we're testing locally with the shim directly.
    unless route
      render json: {status: "route not found"}, status: 404
      return
    end

    # The reason we look up the route is because it contains mounted class info
    mount_class = route.mount_class # IE: RackApp
    env = build_env(route.path)

    status, headers, io = mount_class.call(env)
    body = read_body(io)
    render(
      status: status,
      headers: headers,
      body: body,
    )
  end

private
  # Rack response will return an IO object that responds to each. Sometimes this a Rack::BodyProxy
  # Found this to be the case in Rails and Grape.
  # Doing an IO#read may not work. So we'll always use the IO#each method
  def read_body(io)
    result = []
    io.each { |body| result << body }
    result.join
  end

  # Locally Jets::Router::Finder gets called twice because it also gets called in Jets::Controller::Middleware::Local
  # On Lambda, Jets::Router::Finder only gets called once.
  # TODO: Maybe add caching improvement.
  def find_route
    Jets::Router::Finder.new(event["path"], "ANY").run
  end

  def build_env(path)
    env = Jets::Controller::Rack::Env.new(event, context, adapter: true).convert
    # remap path info
    mount_at = mount_at(path)
    path_info = env["PATH_INFO"]
    env["SCRIPT_NAME"] = script_name(mount_at)
    env["PATH_INFO"] = path_info.sub(mount_at,'')
    env["ORIGINAL_PATH_INFO"] = path_info
    env
  end

  # Removes the wildcard: rack/*path => rack
  def mount_at(path)
    path.gsub(/\*.*/,'')
  end

  # Adding forward slash to script name, to generate proper path.
  # First remove all the occurance of forward slash at the begining and then add one.
  def script_name(path)
    '/' + path.gsub(/^\/*/,'')
  end
end
