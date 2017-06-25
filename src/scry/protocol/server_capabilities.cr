module Scry
  struct ServerCapabilities < ResponseMessage

    enum TextDocumentSyncKind
      None
      Full
      Incremental
    end

    def initialize(@msg_id : Int32)
      super(@msg_id, TextDocumentSyncKind::Full.value)
    end


  end
end
