module Scry

  struct Response

    def initialize(@payload : String)
    end

    def to_s
      "Content-Length: #{@payload.size}\r\n\r\n#{@payload}"
    end

  end

end
