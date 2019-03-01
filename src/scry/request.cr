require "./log"
require "./headers"

module Scry
  struct Request
    getter headers = Headers.new
    getter content : String?

    def initialize(@io : IO)
      read_headers
      @content = read_content
    end

    private def read_headers
      loop do
        header = read_header
        break if header.nil?
        @headers.add(header)
      end
    end

    private def read_header
      raw_header = @io.gets
      Log.logger.debug(raw_header)

      if raw_header.nil?
        if Scry.shutdown
          Log.logger.info("Server has shut down, no more request are accepted")
          exit(0)
        else
          Log.logger.warn("Connection with client lost")
          nil
        end
      else
        header = raw_header.chomp
        header.size == 0 ? nil : header
      end
    end

    private def read_content
      @content = @io.gets(content_length)
      Log.logger.debug(@content)
      @content
    end

    private def content_length
      @headers.content_length
    end
  end
end
