module Scry

  class Response

    private getter results : Array(PublishDiagnosticsNotification | ServerCapabilities | Nil)

    def initialize(@results)
    end

    def write(io)
      results.compact.each do |result|
        io << prepend_header(result.to_json)
      end
      io.flush
    end

    private def prepend_header(content : String)
      "Content-Length: #{content.size}\r\n\r\n#{content}"
    end

  end

end
