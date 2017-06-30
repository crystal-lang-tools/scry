require "./initialize_params"

module Scry
  struct RequestMessage
    JSON.mapping({
      jsonrpc: String,
      id:      Int32,
      method:  String,
      params:  InitializeParams?,
    })
  end
end
