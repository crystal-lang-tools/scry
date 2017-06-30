require "json"

module Scry
  struct InitializeParams
    JSON.mapping({
      process_id:   {type: Int64 | Int32, key: "processId"},
      root_uri:     {type: String, key: "rootPath"},
      capabilities: JSON::Any,
      trace:        String,
    })

  end
end
