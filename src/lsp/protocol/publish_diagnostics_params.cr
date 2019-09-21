module LSP::Protocol
  struct PublishDiagnosticsParams
    JSON.mapping({
      uri:         String,
      diagnostics: Array(Diagnostic),
    }, true)

    def initialize(@uri, @diagnostics)
    end
  end
end
