module Translatomatic
  class HTTPRequest

    def initialize(url)
      @uri = url.kind_of?(String) ? URI.parse(url) : url
    end

    def start(options = {})
      options = options.merge(use_ssl: @uri.scheme == "https")
      Net::HTTP.start(@uri.host, @uri.port, options) do |http|
        @http = http
        yield http
      end
      @http = nil
    end

    def get(query = nil)
      uri = @uri
      if query
        uri = @uri.dup
        uri.query = URI.encode_www_form(query)
      end
      request = Net::HTTP::Get.new(uri)
      send_request(request)
    end

    def post(body, options = {})
      request = Net::HTTP::Post.new(@uri)
      request.body = body
      request.content_type = options[:content_type] if options[:content_type]
      send_request(request)
    end

    private

    def send_request(req)
      response = @http.request(req)
      raise response.body unless response.kind_of? Net::HTTPSuccess
      response
    end
  end # class
end   # module
