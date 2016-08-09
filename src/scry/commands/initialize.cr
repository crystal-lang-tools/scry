require "../workspace"

module Scry

  struct ServerCapabilities

    TEXT_DOCUMENT_SYNC_NONE = 0
    TEXT_DOCUMENT_SYNC_FULL = 1
    TEXT_DOCUMENT_SYNC_INCREMENTAL = 2

    def initialize
      @text_document_sync = TEXT_DOCUMENT_SYNC_FULL as Int32
    end

    def to_json(io)
      io.json_object do |cap|
        cap.field "capabilities" do
          io.json_object do |object|
            object.field "textDocumentSync", @text_document_sync
          end
        end
      end
    end

    def to_json
      String.build { |io| to_json(io) }
    end

  end


  class Initialize

    private getter workspace : Workspace

    def initialize(params : InitializeParams)
      @workspace = Workspace.new(
        root_path: params.root_path,
        process_id: params.process_id,
        max_number_of_problems: 100
      )
    end

    def run
      { @workspace, response }
    end

    private def response
      ServerCapabilities.new
    end

  end

end