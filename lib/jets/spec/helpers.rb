# frozen_string_literal: true

require 'base64'

module Jets
  module Spec
    module Helpers
      Params = Struct.new(:path_params, :body_params)

      Request = Struct.new(:method, :path, :headers, :params) do
        def event_hash
          json = {}
          id_params = path.scan(%r{:([^/]+)}).flatten
          expanded_path = path.dup
          path_parameters = {}

          id_params.each do |id_param|
            raise "missing param: :#{id_param}" unless params.path_params.include? id_param.to_sym

            path_param_value = params.path_params[id_param.to_sym]
            raise "Path param :#{id_param} value cannot be blank" if path_param_value.blank?

            expanded_path.gsub!(":#{id_param}", path_param_value.to_s)
            path_parameters.deep_merge!(id_param => path_param_value.to_s)
          end

          json['resource'] = path
          json['path'] = expanded_path
          json['httpMethod'] = method.to_s.upcase
          json['pathParameters'] = path_parameters
          json['headers'] = (headers || {}).stringify_keys

          if method != :get
            json['headers']['Content-Type'] = "multipart/form-data; boundary=#{multipart_boundary}"
            body = +''
            params.body_params.to_a.each do |e|
              key, value = e
              body << multipart_item(name: key, value: value)
            end
            body << multipart_end

            json['body'] = Base64.encode64 body
            json['isBase64Encoded'] = true
          end

          json
        end

        def multipart_boundary
          @boundary ||= '-' * 16 + SecureRandom.hex(32)
        end

        def multipart_item(name:, value:)
          if value.is_a? File
            multipart_file(name: name, filename: File.basename(value.path),
                           data: ::IO.read(value.path))
          else
            multipart_text(name: name, text: value)
          end
        end

        def multipart_text(name:, text:)
          "--#{multipart_boundary}\r\nContent-Disposition: form-data; name=\"#{name}\"\r\n"\
          "Content-Type: text/plain\r\n\r\n#{text}\r\n"
        end

        def multipart_file(name:, filename:, data:)
          "--#{multipart_boundary}\r\nContent-Disposition: form-data; name=\"#{name}\"; "\
          "filename=\"#{filename}\"\r\n\r\n#{data}\r\n"
        end

        def multipart_end
          "--#{multipart_boundary}--"
        end

        def find_route!
          path = self.path
          path = path[0..-2] if path.end_with? '/'
          path = path[1..-1] if path.start_with? '/'

          route = Jets::Router.routes.find { |r| r.path == path && r.method == method.to_s.upcase }
          raise "Route not found: #{method.to_s.upcase} #{path}" if route.blank?

          route
        end

        def dispatch!
          route = find_route!
          controller = Object.const_get(route.controller_name).new(event_hash, {}, route.action_name)
          response = controller.dispatch!

          if !response.is_a?(Array) || response.size != 3
            raise "Expected response to be an array of size 3. Are you rendering correctly?"
          end

          Response.new(response[0].to_i, response[2].read)
        end
      end

      Response = Struct.new(:status, :body)

      def request
        @_request ||= Request.new(:get, '/', {}, Params.new({}, {}))
      end

      def response
        @_response
      end

      def get(path, **params)
        http_call(method: :get, path: path, **params)
      end

      def post(path, **params)
        http_call(method: :post, path: path, **params)
      end

      def put(path, **params)
        http_call(method: :put, path: path, **params)
      end

      def patch(path, **params)
        http_call(method: :patch, path: path, **params)
      end

      def delete(path, **params)
        http_call(method: :delete, path: path, **params)
      end

      def http_call(method:, path:, **params)
        request.method = method.to_sym
        request.path = path
        request.headers.deep_merge!(params.delete(:headers) || {})

        request.params.body_params = params.delete(:params) || params || {}
        request.params.path_params = params

        @_response = request.dispatch!
      end

      def fixture_path(filename)
        "#{Jets.root}/spec/fixtures/#{filename}"
      end

      def fixture_file(filename)
        File.new(fixture_path(filename))
      end
    end
  end
end

RSpec.configure do |c|
  c.include Jets::Spec::Helpers
end