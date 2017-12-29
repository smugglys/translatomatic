require 'securerandom'
require 'net/http'

module Translatomatic
  # HTTP request
  # wrapper for Net::HTTP functionality
  class HTTPRequest

    # @return [String] the text to use to denote multipart boundaries. By
    #   default, a random hexadecimal string is used.
    attr_accessor :multipart_boundary

    # @param [String,URI] url URL of the request
    # @return [Translatomatic::HTTPRequest] Create a new request
    def initialize(url)
      @uri = url.respond_to?(:host) ? url : URI.parse(url)
      @multipart_boundary = SecureRandom.hex(16)
    end

    # Start the HTTP request. Yields a http object.
    # @param [Hash<Symbol,Object>] options Request options
    # @return [void]
    def start(options = {})
      options = options.merge(use_ssl: @uri.scheme == "https")
      Net::HTTP.start(@uri.host, @uri.port, options) do |http|
        @http = http
        yield http
      end
      @http = nil
    end

    # Send a HTTP GET request
    # @param [Hash<String,String>] query Optional query parameters
    # @return [Net::HTTP::Response]
    def get(query = nil)
      uri = @uri
      if query
        uri = @uri.dup
        uri.query = URI.encode_www_form(query)
      end
      request = Net::HTTP::Get.new(uri)
      request['User-Agent'] = USER_AGENT
      send_request(request)
    end

    # Send an HTTP POST request
    # @param [String,Hash] body Body of the request
    # @return [Net::HTTP::Response]
    def post(body, options = {})
      request = Net::HTTP::Post.new(@uri)
      request['User-Agent'] = USER_AGENT
      content_type = options[:content_type]

      if options[:multipart]
        content_type = "multipart/form-data; boundary=#{@multipart_boundary}"
        request.body = multipartify(body)
      elsif body.kind_of?(Hash)
        request.set_form_data(body)
      else
        request.body = body
      end
      request.content_type = content_type if content_type

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

    USER_AGENT = "Translatomatic #{VERSION} (+#{URL})"

    # Formats a basic string key/value pair for a multipart post
    class Param
      attr_accessor :key, :value

      # @return [String] Representation of this parameter as it appears
      #   within a multipart post request.
      def to_s
        return header(header_data) + "\r\n#{value}\r\n"
      end

      private

      def initialize(key:, value:)
        @key = key
        @value = value
      end

      def header_data
        name = CGI::escape(key.to_s)
        { "Content-Disposition": "form-data", name: %Q("#{name}") }
      end

      def header(options)
        out = []
        idx = 0
        options.each do |key, value|
          separator = idx == 0 ? ": " : "="
          out << "#{key}#{separator}#{value}"
          idx += 1
        end
        out.join("; ") + "\r\n"
      end
    end

    # Formats the contents of a file or string for a multipart post
    class FileParam < Param
      attr_accessor :filename, :content, :mime_type

      # (see Param#to_s)
      def to_s
        return header(header_data) +
          header("Content-Type": mime_type) + "\r\n#{content}\r\n"
      end

      private

      def initialize(key:, filename:, content:, mime_type:)
        @key = key
        @filename = filename
        @content = content
        @mime_type = mime_type
      end

      def header_data
        super.merge({ filename: %Q("#{filename}") })
      end
    end

    def multipartify(parts)
      string_parts = parts.collect do |p|
        "--" + @multipart_boundary + "\r\n" + p.to_s
      end
      string_parts.join("") + "--" + @multipart_boundary + "--\r\n"
    end

    def send_request(req)
      response = @http.request(req)
      raise response.body unless response.kind_of? Net::HTTPSuccess
      response
    end

  end # class
end   # module
