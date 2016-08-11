require "json"

module Scry

  struct BuildFailure
    JSON.mapping(
      file: String,
      line: Int32 | Nil,
      column: Int32,
      size: Int32 | Nil,
      message: String
    )
  end

  enum DiagnosticServerity
    Error = 1
    Warning
    Information
    Hint
  end

  class Diagnostic

    private getter filename : String
    private getter line : Int32
    private getter column : Int32
    private getter size : Int32
    private getter message : String

    def initialize(bf : BuildFailure)
      @filename = bf.file
      @line = bf.line || 0
      @column = bf.column
      @size = bf.size || 0
      @message = bf.message
    end

    def initialize(@filename, @line, @column, @size, @message)
    end

    def uri
      "file://#{filename}"
    end

    def to_json
      String.build { |io| to_json(io) }
    end

    def to_json(io)
      io.json_object do |object|
        object.field "range" do
          io.json_object do |range|
            range.field "start" do
              io.json_object do |pos|
                pos.field "line", line - 1
                pos.field "character", column - 1
              end
            end
            range.field "end" do
              io.json_object do |pos|
                pos.field "line", line - 1
                pos.field "character", column + size - 1
              end
            end
          end
        end
        object.field "severity", DiagnosticServerity::Error
        object.field "source", "Scry [Crystal]"
        object.field "message", message
      end
    end

  end

end
