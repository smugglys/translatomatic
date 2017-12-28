require 'securerandom'
require 'net/http'

module Translatomatic
  class HTTPRequest

    attr_accessor :multipart_boundary

    def initialize(url)
      @uri = url.respond_to?(:host) ? url : URI.parse(url)
      @multipart_boundary = SecureRandom.hex(16)
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
      request['User-Agent'] = USER_AGENT
      send_request(request)
    end

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

    def file(*args)
      FileParam.new(*args)
    end

    def param(*args)
      Param.new(*args)
    end

    private

    USER_AGENT = "Translatomatic #{VERSION} (+#{URL})"

    # Formats a basic string key/value pair for a multipart post
    class Param
      attr_accessor :key, :value

      def initialize(key:, value:)
        @key = key
        @value = value
      end

      def to_s
        return header(header_data) + "\r\n#{value}\r\n"
      end

      private

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

      def initialize(key:, filename:, content:, mime_type:)
        @key = key
        @filename = filename
        @content = content
        @mime_type = mime_type
      end

      def to_s
        return header(header_data) +
          header("Content-Type": mime_type) + "\r\n#{content}\r\n"
      end

      private

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
