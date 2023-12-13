module Jets::Shim::Response
  class Alb < Apigw
    def translate
      hash = super
      desc = Rack::Utils::HTTP_STATUS_CODES[hash[:statusCode]]
      hash[:statusDescription] = "#{hash[:statusCode]} #{desc}"
      hash
    end
  end
end
