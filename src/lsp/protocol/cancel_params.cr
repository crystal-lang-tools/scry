module LSP::Protocol
  struct CancelParams
    JSON.mapping({
      id: Int32 | String,
    }, true)
  end
end
