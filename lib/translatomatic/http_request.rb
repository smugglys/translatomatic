require 'securerandom'
require 'net/http'

module Translatomatic
  # HTTP request
  # wrapper for Net::HTTP functionality
  class HTTPRequest
    # @return [String] the text to use to denote multipart boundaries. By
    #   default, a random hexadecimal string is used.
    attr_accessor :multipart_boundary

    # @param url [String,URI] URL of the request
    # @return [Translatomatic::HTTPRequest] Create a new request
    def initialize(url, options = {})
      @uri = url.respond_to?(:host) ? url : URI.parse(url)
      @multipart_boundary = SecureRandom.hex(16)
      @redirects = options[:redirects] || 0
      raise 'Maximum redirects exceeded' if @redirects > MAX_REDIRECTS
    end

    # Start the HTTP request. Yields a http object.
    # @param options [Hash<Symbol,Object>] Request options
    # @return [Object] Result of the block
    def start(options = {})
      options = options.merge(use_ssl: @uri.scheme == 'https')
      result = nil
      Net::HTTP.start(@uri.host, @uri.port, options) do |http|
        @http = http
        result = yield http
      end
      @http = nil
      result
    end

    # Send a HTTP GET request
    # @param query [Hash<String,String>] Optional query parameters
    # @return [Net::HTTP::Response]
    def get(query = nil, options = {})
      uri = @uri
      if query
        uri = @uri.dup
        uri.query = URI.encode_www_form(query)
      end
      request = Net::HTTP::Get.new(uri)
      configure_request(request, options)
      send_request(request)
    end

    # Send an HTTP POST request
    # @param body [String,Hash] Body of the request
    # @return [Net::HTTP::Response]
    def post(body, options = {})
      request = Net::HTTP::Post.new(@uri)
      configure_request(request, options.merge(body: body))
      send_request(request)
    end

    # Create a file parameter for a multipart POST request
    # @return [FileParam] A new file parameter
    def file(*args)
      FileParam.new(*args)
    end

    # Create a parameter for a multipart POST request
    # @return [Param] A new parameter
    def param(*args)
      Param.new(*args)
    end

    private

    USER_AGENT = "Translatomatic #{VERSION} (+#{URL})".freeze
    MAX_REDIRECTS = 5

    # Formats a basic string key/value pair for a multipart post
    class Param
      attr_accessor :key, :value

      # @return [String] Representation of this parameter as it appears
      #   within a multipart post request.
      def to_s
        header(header_data) + "\r\n#{value}\r\n"
      end

      private

      def initialize(key:, value:)
        @key = key
        @value = value
      end

      def header_data
        name = CGI.escape(key.to_s)
        { 'Content-Disposition' => 'form-data', name: %("#{name}") }
      end

      def header(options)
        out = []
        idx = 0
        options.each do |key, value|
          separator = idx.zero? ? ': ' : '='
          out << "#{key}#{separator}#{value}"
          idx += 1
        end
        out.join('; ') + "\r\n"
      end
    end

    # Formats the contents of a file or string for a multipart post
    class FileParam < Param
      attr_accessor :filename, :content, :mime_type

      # (see Param#to_s)
      def to_s
        header(header_data) +
          header('Content-Type' => mime_type) + "\r\n#{content}\r\n"
      end

      private

      def initialize(key:, filename:, content:, mime_type:)
        @key = key
        @filename = filename
        @content = content
        @mime_type = mime_type
      end

      def header_data
        super.merge(filename: %("#{filename}"))
      end
    end

    def multipartify(parts)
      string_parts = parts.collect do |p|
        '--' + @multipart_boundary + "\r\n" + p.to_s
      end
      string_parts.join('') + '--' + @multipart_boundary + "--\r\n"
    end

    def configure_request(request, options)
      request['User-Agent'] = USER_AGENT

      (options[:headers] || {}).each do |key, value|
        request[key] = value
      end

      content_type = options[:content_type]
      body = options[:body]

      if body
        if options[:multipart]
          boundary = "boundary=#{@multipart_boundary}"
          content_type = 'multipart/form-data; ' + boundary
          request.body = multipartify(body)
        elsif body.is_a?(Hash)
          # set_form_data does url encoding
          request.set_form_data(body)
        else
          request.body = body
        end
      end

      request.content_type = content_type if content_type
    end

    def send_request(req)
      response = if @http
                   @http.request(req)
                 else
                   start { |_http| send_request(req) }
                 end
      handle_response(response)
    end

    def handle_response(response)
      case response
      when Net::HTTPSuccess
        response
      when Net::HTTPRedirection
        location = URI.parse(response['Location'])
        puts location
        new_uri = location.relative? ? @uri + response.location : location
        self.class.new(new_uri, redirects: @redirects + 1).get
      else
        # error
        raise response.body
      end
    end
  end
end
