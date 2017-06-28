module Scry

  struct TextEdit
    JSON.mapping(
      range: Range,
      newText: String
    )
    def initialize(@range, @newText)
    end
  end

  struct ErrCodeMsg
    JSON.mapping(
      code: Int32,
      message: String
    )
    def initialize(@code, @message)
    end
  end

  struct PublishFormatNotification
    JSON.mapping(
      jsonrpc: String,
      id: Int32,
      result: Array(TextEdit)
    )

    def initialize(@id : Int32, text : String)
      @jsonrpc = "2.0"
      r = Range.new(Position.new(0,0), Position.new(text.split('\n').size, text.split('\n').last.size))
      @result = [TextEdit.new(r, text)]
    end
  end
end