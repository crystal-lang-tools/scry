require "./diagnostic"

module Scry
  struct PublishDiagnosticsParams
    JSON.mapping({
      uri:         String,
      diagnostics: Array(Diagnostic),
    }, true)

    def initialize(@uri, @diagnostics)
    end
  end
end
