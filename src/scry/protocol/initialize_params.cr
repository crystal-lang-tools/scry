require "json"

module Scry

  struct InitializeParams
    JSON.mapping({
      process_id: { type: Int64, key: "processId" },
      root_path: { type: String, key: "rootPath" },
      capabilities: JSON::Any,
      trace: String
    }, true)
  end

end