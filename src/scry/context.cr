require "json"
require "./workspace"

module Scry

  class UnrecognizedProcedureError < Exception; end

  class InvalidRequestError < Exception; end

  class ServerCapabilities

    TEXT_DOCUMENT_SYNC_NONE = 0
    TEXT_DOCUMENT_SYNC_FULL = 1
    TEXT_DOCUMENT_SYNC_INCREMENTAL = 2

    JSON.mapping(
      text_document_sync: {
        type: Int32,
        key: "textDocumentSync"
      }
    )
  end

  struct InitializeResponse
    JSON.mapping(
      capabilities: { type: ServerCapabilities }
    )
  end

  class Context

    def dispatch(rpc : Scry::RemoteProcedureCall)
      case rpc.method
      when "initialize"
        @workspace = Workspace.new(rpc.params)
        initialize_response
      else
        raise UnrecognizedProcedureError.new(rpc.method)
      end
    end

    def dispatch(notification : NotificationEvent)
      case notification.method
      when "workspace/didChangeConfiguration"
        workspace.config_changed(notification.params)

      when "textDocument/didOpen"
        workspace.analyze(notification.params)
      else
        raise UnrecognizedProcedureError.new(
          "Unrecognized procedure: #{notification.method}"
        )
      end
    end

    # This works around some issues with Nil detection being too strict.
    private def workspace : Workspace
      @workspace || raise InvalidRequestError.new(
        "An initialize request must be sent first"
      )
    end

    private def initialize_response
      InitializeResponse.from_json({
        capabilities: server_capabilities
      }.to_json)
    end

    private def server_capabilities
      ServerCapabilities.from_json({
        textDocumentSync: ServerCapabilities::TEXT_DOCUMENT_SYNC_FULL
      }.to_json)
    end

  end

end
