module LSP::Protocol
  struct InitializeParams
    JSON.mapping({
      process_id:   {type: Int64 | Int32 | Nil, key: "processId", nilable: true},
      root_uri:     {type: String | Nil, key: "rootUri"},
      root_path:    {type: String | Nil, key: "rootPath", nilable: true},
      capabilities: JSON::Any,
      trace:        String?,
    })
  end
end
