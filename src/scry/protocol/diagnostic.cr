require "json"

module Scry

  struct BuildFailure
    JSON.mapping(
      file: String,
      line: Int32,
      column: Int32,
      size: Int32 | Nil,
      message: String
    )
  end

  class Diagnostic

    @bf : BuildFailure

    def initialize(bf : BuildFailure)
      @bf = bf
    end

    def filename
      @bf.file
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
                pos.field "line", @bf.line - 1
                pos.field "character", @bf.column - 1
              end
            end
            range.field "end" do
              io.json_object do |pos|
                pos.field "line", @bf.line - 1
                pos.field "character", @bf.column + (@bf.size || 0) - 1
              end
            end
          end
        end
        object.field "severity", 1 # Right now, everything is an error
        object.field "source", "Scry [Crystal]"
        object.field "message", @bf.message
      end
    end
  end

end