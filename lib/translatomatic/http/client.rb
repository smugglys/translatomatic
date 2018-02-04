require 'http-cookie'

module Translatomatic
  module HTTP
    # HTTP client
    class Client
      def initialize(options = {})
        @redirects = 0
        @jar = ::HTTP::CookieJar.new
        @retry_delay = options[:retry_delay] || 2
      end

      # Send an HTTP GET request
      # @param url [String,URI] URL of the request
      # @param query [Hash<String,String>] Optional query parameters
      # @param options [Hash<Symbol,Object>] Request options
      # @return [Net::HTTP::Response]
      def get(url, query = nil, options = {})
        send_request_with_method(:get, url, options.merge(query: query))
      end

      # Send an HTTP POST request
      # @param url [String,URI] URL of the request
      # @param body [String,Hash] Body of the request
      # @param options [Hash<Symbol,Object>] Request options
      # @return [Net::HTTP::Response]
      def post(url, body, options = {})
        send_request_with_method(:post, url, options.merge(body: body))
      end

      # Send an HTTP HEAD request
      # @param url [String,URI] URL of the request
      # @param options [Hash<Symbol,Object>] Request options
      # @return [Net::HTTP::Response]
      def head(url, options = {})
        send_request_with_method(:head, url, options)
      end

      # Send an HTTP DELETE request
      # @param url [String,URI] URL of the request
      # @param options [Hash<Symbol,Object>] Request options
      # @return [Net::HTTP::Response]
      def delete(url, options = {})
        send_request_with_method(:delete, url, options)
      end

      # Start an HTTP request. Yields the http object.
      # @param url [String,URI] URL of the request, requires host and port
      # @return [Object] The result of the yielded block
      def start(url, _options = {})
        uri = url.respond_to?(:host) ? url : URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        # http.set_debug_output(Translatomatic.config.logger) if ENV['DEBUG']
        result = http.start do
          @http = http
          yield http
        end
        @http = nil
        result
      end

      private

      include Util

      MAX_REDIRECTS = 5
      RETRIABLE = [Net::HTTPServerError, Net::HTTPTooManyRequests].freeze
      RETRIABLE_CODES = [408].freeze

      # Retry requests on server errors
      class HttpRetryExecutor < RetryExecutor
        def retriable?(exception)
          http_exception?(exception) && retriable_exception?(exception)
        end

        def http_exception?(exception)
          exception.is_a?(Translatomatic::HTTP::Exception)
        end

        def retriable_exception?(exception)
          RETRIABLE.any? { |i| exception.response.kind_of?(i) } ||
            RETRIABLE_CODES.include?(exception.response.code.to_i)
        end
      end

      def send_request_with_method(method, url, options = {})
        cookies = ::HTTP::Cookie.cookie_value(@jar.cookies(url))
        options = options.merge(cookies: cookies) if cookies.present?
        request = Request.new(method, url, options)
        send_request(request)
      end

      def send_request(req)
        executor = HttpRetryExecutor.new(retry_delay: @retry_delay)
        executor.run { handle_response(send_request_http(req)) }
      end

      def send_request_http(req)
        if @http
          log.debug("HTTP request: #{req.http_request.uri}")
          @http.request(req.http_request)
        else
          start(req.uri) { |_http| send_request_http(req) }
        end
      end
 
      def save_cookies(response)
        cookies = response.get_fields('set-cookie')
        return unless cookies
        cookies.each { |i| @jar.parse(i, response.uri) }
      end

      def handle_response(response)
        log.debug("HTTP response: #{response.code} #{response.msg}")

        case response
        when Net::HTTPSuccess
          @redirects = 0
          save_cookies(response)
          response
        when Net::HTTPRedirection
          @redirects += 1
          raise 'Maximum redirects exceeded' if @redirects > MAX_REDIRECTS
          new_uri = redirect_uri(response)
          get(new_uri, nil)
        else
          # error
          @redirects = 0
          raise Translatomatic::HTTP::Exception, response
        end
      end

      def redirect_uri(response)
        location = URI.parse(response['Location'])
        if location.relative?
          response.uri + response.location
        else
          location
        end
      end
    end
  end
end
