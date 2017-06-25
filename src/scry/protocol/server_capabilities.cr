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

    # def to_json
    #   ResponseMessage
    #     .new(@msg_id)
    #     .compose_json {
    #     JSON.build do |json|
    #       json.object do
    #         json.field "capabilities" do
    #           json.object do
    #             json.field "textDocumentSync", @text_document_sync.value
    #           end
    #         end
    #       end
    #     end
    #   }
    # end

    # def to_json
    #   String.build { |io| to_json(io) }
    # end

  end
end
