module Scry
  struct DiagnosticParams
    JSON.mapping(
      uri: String,
      diagnostics: Array(Diagnostic)
    )
    def initialize(@uri, @diagnostics)
    end
  end

  abstract struct Notification
    JSON.mapping(
      jsonrpc: String,
      method: String,
      params: DiagnosticParams
    )

    def initialize(@method, uri : String, diagnostics : Array(Diagnostic))
      @jsonrpc = "2.0"
      @params = DiagnosticParams.new(uri, diagnostics)
    end

  end
end
