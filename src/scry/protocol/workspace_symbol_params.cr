require "json"

module Scry
  struct WorkspaceSymbolParams
    JSON.mapping({
      query: String,
    }, true)
  end
end
