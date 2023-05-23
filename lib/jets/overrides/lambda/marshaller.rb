require 'json'

# Hack AwsLambda Ruby Runtime to fix .to_json issue collision with ActiveSupport.
# To reproduce:
#   Create a shared resource from the docs and call sns.publish
#
# Causes an infinite loop when calling sns.publish somehow.
# Overriding with JSON.dump and follow up with AWS ticket.
module AwsLambda
  class Marshaller
    class << self
      # By default, just runs #to_json on the method's response value.
      # This can be overwritten by users who know what they are doing.
      # The response is an array of response, content-type.
      # If returned without a content-type, it is assumed to be application/json
      # Finally, StringIO/IO is used to signal a response that shouldn't be
      # formatted as JSON, and should get a different content-type header.
      def marshall_response(method_response)
        case method_response
        when StringIO, IO
          [method_response, 'application/unknown']
        else
          # Orignal method calls .to_json but this collides with ActiveSupport's to_json
          # method_response.to_json # application/json is assumed
          # https://stackoverflow.com/questions/18067203/ruby-to-json-issue-with-error-illegal-malformed-utf-8
          if method_response.is_a?(Hash)
            method_response.deep_transform_values! do |v|
              if v.respond_to?(:force_encoding) && !v.frozen?
                v.force_encoding("ISO-8859-1").encode("UTF-8")
              else
                v # IE: Integer
              end
            end
          end
          JSON.dump(method_response)
        end
      end

    end
  end
end
