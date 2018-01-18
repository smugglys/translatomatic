require 'securerandom'
require 'net/http'

module Translatomatic
  module HTTP
    # HTTP request
    # wrapper for Net::HTTP functionality
    class Request
      # @return [String] the text to use to denote multipart boundaries. By
      #   default, a random hexadecimal string is used.
      attr_accessor :multipart_boundary

      # @return [String] the HTTP body
      attr_accessor :body

      # @return [URI] the URI of the request
      attr_reader :uri

      # @return [String] the HTTP method
      attr_reader :method

      # @param method [Symbol] HTTP method
      # @param url [String,URI] URL of the request
      # @return [Translatomatic::HTTPRequest] Create a new request
      def initialize(method, url, options = {})
        @method = method
        @options = options
        @uri = url.respond_to?(:host) ? url.dup : URI.parse(url)
        query = options[:query]
        @uri.query = URI.encode_www_form(query) if query
        @multipart_boundary = generate_multipart_boundary
        @body = @options[:body]
      end

      # @return [Object] The request object for use with Net::HTTP
      def http_request
        @request ||= create_request
      end

      private

      def generate_multipart_boundary
        SecureRandom.hex(16)
      end

      def multipartify(parts)
        string_parts = parts.collect do |i|
          part = paramify(i)
          '--' + @multipart_boundary + "\r\n" + part.to_s
        end
        string_parts.join('') + '--' + @multipart_boundary + "--\r\n"
      end

      def paramify(object)
        return object if object.kind_of?(Param)
        raise "invalid multipart parameter" unless object.is_a?(Hash)
        object[:filename] ? FileParam.new(object) : Param.new(object)
      end

      def create_request
        klass = Net::HTTP.const_get(@method.to_s.classify)
        request = klass.new(@uri)
        request['User-Agent'] = USER_AGENT

        (@options[:headers] || {}).each do |key, value|
          request[key] = value
        end

        request['Cookie'] = @options[:cookies] if @options[:cookies]

        content_type = @options[:content_type]

        if body
          if @options[:multipart] || body.is_a?(Array)
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
        request
      end

    end
  end
end
