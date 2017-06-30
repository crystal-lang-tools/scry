require "./log"
require "./protocol/response_message"
require "./protocol/initialize"
require "./publish_diagnostic"

module Scry
  alias Result = Initialize | ResponseMessage | NotificationMessage | Nil

  struct Response
    @results : Array(Result)

    def initialize(@results)
    end

    def write(io)
      @results.compact.each do |result|
        log_and_write(io, prepend_header(result.to_json))
      end
      io.flush
    end

    private def log_and_write(io, content)
      Log.logger.debug(%(Content SEND: #{content}))
      io << content
    end

    private def prepend_header(content : String)
      "Content-Length: #{content.bytesize}\r\n\r\n#{content}"
    end
  end
end
