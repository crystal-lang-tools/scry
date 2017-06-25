require "json"

module Scry
  struct BuildFailure
    JSON.mapping(
      file: String,
      line: Int32?,
      column: Int32,
      size: Int32?,
      message: String
    )
  end

  enum DiagnosticServerity
    Error       = 1
    Warning
    Information
    Hint
  end

  struct LineColumn
    JSON.mapping(
      line: Int32,
      character: Int32
    )

    def initialize(@line, @character)
    end
  end

  struct DiagnosticRange
    JSON.mapping(
      "start": LineColumn,
      "end": LineColumn
    )

    def initialize(@start, @end)
    end
  end

  class Diagnostic
    JSON.mapping(
      range: DiagnosticRange,
      severity: Int32,
      source: String,
      message: String
    )
    private getter filename = ""
    private getter line = 0
    private getter column = 1
    private getter size = 1

    # private getter message : String

    def initialize(bf : BuildFailure)
      initialize(bf.file, bf.line || 0, bf.column, bf.size || 1, bf.message)
    end

    def initialize(@filename, @line, @column, @size, @message)
      @range = DiagnosticRange.new(
        LineColumn.new(line - 1, column - 1),
        LineColumn.new(line - 1, column + size - 1)
      )
      @severity = DiagnosticServerity::Error.value
      @source = "Scry [Crystal]"
    end

    def uri
      if filename.starts_with?("untitled:")
        filename
      else
        "file://#{filename}"
      end
    end


  end
end
