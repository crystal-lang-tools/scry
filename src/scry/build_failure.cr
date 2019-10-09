module Scry
  # Failure JSON output by Crystal compiler
  struct BuildFailure
    JSON.mapping({
      file:    String,
      line:    Int32?,
      column:  Int32,
      size:    Int32?,
      message: String,
    }, true)

    def build_lsp_diagnostic
      LSP::Protocol::Diagnostic.new(file, line, column, size, message, "Scry")
    end
  end
end
