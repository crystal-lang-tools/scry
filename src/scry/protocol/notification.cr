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

    # def compose_json
    #   JSON.build do |object|
    #     object.object do
    #       object.field "", "2.0"
    #       object.field "", @method
    #       object.field "" do
    #         yield
    #       end
    #     end
    #   end
    # end
  end
end
