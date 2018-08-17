require "json"

module Scry::Protocol
  struct WorkspaceSymbolParams
    JSON.mapping({
      query: String,
    }, true)
  end
end
