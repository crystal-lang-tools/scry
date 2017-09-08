require "./initialize_params"

module Scry
  struct RequestMessage
    alias RequestType = (TextDocumentPositionParams |
                         InitializeParams |
                         DocumentFormattingParams)?

    JSON.mapping({
      jsonrpc: String,
      id:      Int32,
      method:  String,
      params:  RequestType,
    })
  end
end
