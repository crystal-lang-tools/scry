module Scry
  enum TextDocumentSyncKind
    None
    Full
    Incremental
  end

  struct CrystalServerCapabilities
    JSON.mapping(
      documentFormattingProvider: Bool,
      textDocumentSync: TextDocumentSyncKind
    )
    def initialize(
      @documentFormattingProvider,
      @textDocumentSync
    )
    end
  end

  struct ServerCapabilities < ResponseMessage
    def initialize(msg_id : Int32)
      capabilities = CrystalServerCapabilities.new(
        documentFormattingProvider: true,
        textDocumentSync: TextDocumentSyncKind::Full
      )
      super(msg_id, capabilities)
    end
  end
end
