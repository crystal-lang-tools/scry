module LSP::Protocol
  struct DidChangeConfigurationParams
    JSON.mapping({
      settings: Settings,
    }, true)
  end
end
