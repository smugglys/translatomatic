require "execjs/runtime"

ENV['EXECJS_RUNTIME'] = 'Translatomatic::MockJSRuntime'

module Translatomatic
  class MockJSRuntime < ExecJS::Runtime
    def self.available?
      true
    end
  end
end