module Scry

  struct ServerCapabilities

    enum TextDocumentSyncKind
      None
      Full
      Incremental
    end

    @text_document_sync : TextDocumentSyncKind

    def initialize(@msg_id : Int32)
      @text_document_sync = TextDocumentSyncKind::Full
    end

    def to_json(io)
      ResponseMessage
        .new(@msg_id)
        .compose_json(io) {
          io.json_object do |cap|
            cap.field "capabilities" do
              io.json_object do |object|
                object.field "textDocumentSync", @text_document_sync
              end
            end
          end
        }
    end

    def to_json
      String.build { |io| to_json(io) }
    end

  end

end
