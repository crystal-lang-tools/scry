module LSP::Protocol
  struct WorkspaceSymbolParams
    JSON.mapping({
      query: String,
    }, true)
  end
end
