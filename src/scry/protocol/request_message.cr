require "./initialize_params"

module Scry
  struct RequestMessage
    JSON.mapping({
      jsonrpc: String,
      id:      Int32,
      method:  String,
      params:  {type: InitializeParams, default: InitializeParams.new},
    })
  end
end
