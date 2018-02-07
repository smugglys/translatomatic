module Translatomatic
  # HTTP request functionality
  module HTTP
    # @private
    USER_AGENT = "Translatomatic #{VERSION} (+#{URL})".freeze
  end
end

require 'translatomatic/http/exception'
require 'translatomatic/http/param'
require 'translatomatic/http/file_param'
require 'translatomatic/http/request'
require 'translatomatic/http/client'
