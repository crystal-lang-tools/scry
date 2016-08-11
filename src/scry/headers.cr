module Scry

  class MalformedHeaderError < Exception; end

  class Headers

    record ContentLength,
      value : Int32

    record ContentType,
      value : String

    private getter :headers

    def initialize
      @headers = [] of ContentLength | ContentType
    end

    def add(header : String)
      headers << parse(header)
    end

    def content_length
      length = headers
        .map { |h| content_length(h) }
        .find { |v| !v.nil? }

      length || raise MalformedHeaderError.new(
        "Content-Length header is required. Ex: Content-Length: 132\\r\\n"
      )
    end

    private def content_length(header : ContentLength)
      header.value
    end

    private def content_length(header : ContentType)
      nil
    end

    private def parse(header : String)
      header_parts = header.split(": ")
      raise MalformedHeaderError.new(
        "Each header field should be comprised of a name and a value, separated by \": \" --> #{header}"
      ) unless header_parts.size == 2
      create_header header_parts[0], header_parts[1]
    end

    private def create_header(name, value)
      case name
      when "Content-Length"
        num = value.to_i?
        raise MalformedHeaderError.new(
          "Content-Length expect an integer value. Got --> #{value}"
        ) if num.nil?
        return ContentLength.new(num)
      when "Content-Type"
        return ContentType.new(value)
      else
        raise MalformedHeaderError.new(
          "Unrecognized header. Expected one of [Content-Length, Content-Type] --> #{name}"
        )
      end
    end

  end

end