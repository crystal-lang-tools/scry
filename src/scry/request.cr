require "./log"
require "./headers"

module Scry
  struct Request
    def initialize(@io : IO)
      @headers = Headers.new
      @content = uninitialized String | Nil
    end

    def read
      return @content if @content
      read_headers
      read_content
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
      Log.debug { raw_header }

      if raw_header.nil?
        if Scry.shutdown
          Log.info { "Server has shut down, no more request are accepted" }
          exit(0)
        else
          Log.warn { "Connection with client lost" }
          nil
        end
      else
        header = raw_header.chomp
        header.size == 0 ? nil : header
      end
    end

    private def read_content
      @content = @io.gets(content_length)
      Log.debug { @content }
      @content
    end

    private def content_length
      @headers.content_length
    end
  end
end
