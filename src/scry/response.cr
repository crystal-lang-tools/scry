require "json"
require "./protocol/*"
require "./log"

module Scry

  class Response

    private getter results : Array(
      PublishDiagnosticsNotification |
      PublishFormatNotification |
      ServerCapabilities |
      ErrorMessage |
      Nil
    )

    def initialize(@results)
    end

    def write(io)
      results.compact.each do |result|
        log_and_write io, prepend_header(result.to_json)
      end
      io.flush
    end

    private def log_and_write(io, content)
      Log.logger.debug { %(Content SEND: #{content}) }
      io << content
    end

    private def prepend_header(content : String)
      "Content-Length: #{content.size}\r\n\r\n#{content}"
    end

  end

end
