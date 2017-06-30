require "./analyzer"
require "./workspace"
require "./formatter"
require "./initializer"
require "./implementations"
require "./update_config"
require "./parse_analyzer"
require "./publish_diagnostic"

module Scry
  class UnrecognizedProcedureError < Exception
  end

  class InvalidRequestError < Exception
  end

  struct Context
    def initialize
      @workspace = Workspace.new("", 0, 0)
    end

    # A request message to describe a request between the client and the server.
    # Every processed request must send a response back to the sender of the request.
    # See, https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#shutdown-request
    # NOTE: For some reason the client doesn't accept `ResponseMessage.new(nil)` on shutdown even with emit_null.
    def dispatch(msg : RequestMessage)
      exit(0) if msg.method == "shutdown"
      Log.logger.debug(msg.method)
      if params = msg.params
        dispatchRequest(params, msg)
      end
    end

    def dispatch(msg : NotificationMessage)
      Log.logger.debug(msg.method)
      dispatchNotification(msg.params, msg)
    end

    private def dispatchRequest(params : InitializeParams, msg)
      initializer = Initializer.new(params, msg.id)
      @workspace, response = initializer.run
      response
    end

    private def dispatchNotification(params : DidChangeConfigurationParams, msg)
      updater = UpdateConfig.new(@workspace, params)
      @workspace, response = updater.run
      response
    end

    private def dispatchNotification(params : DidOpenTextDocumentParams, msg)
      text_document = TextDocument.new(params)

      unless text_document.in_memory?
        analyzer = Analyzer.new(@workspace, text_document)
        response = analyzer.run
        response
      end
    end

    private def dispatchNotification(params : DidChangeTextDocumentParams, msg)
      text_document = TextDocument.new(params)
      analyzer = ParseAnalyzer.new(@workspace, text_document)
      response = analyzer.run
      response
    end

    private def dispatchNotification(params : DidChangeWatchedFilesParams, msg)
      params.changes.map { |file_event|
        handle_file_event(file_event)
      }.compact
    end

    # Also used by methods like Go to Definition
    private def dispatchNotification(params : TextDocumentPositionParams, msg)
      case msg.method
      when "textDocument/didSave"
        nil
      when "textDocument/didClose"
        nil
      when "textDocument/definition"
        text_document = TextDocument.new(params, msg.id)
        definitions = Implementations.new(text_document)
        response = definitions.run
        Log.logger.debug(response)
        response
      else
        raise UnrecognizedProcedureError.new("Didn't recognize procedure: #{msg.method}")
      end
    end

    private def dispatchNotification(params : DocumentFormattingParams, msg)
      text_document = TextDocument.new(params, msg.id)

      unless text_document.untitled?
        formatter = Formatter.new(@workspace, text_document)
        response = formatter.run
        Log.logger.debug(response)
        response
      end
    end

    private def handle_file_event(file_event : FileEvent)
      text_document = TextDocument.new(file_event)

      case file_event.type
      when FileEventType::Created
        analyzer = Analyzer.new(@workspace, text_document)
        response = analyzer.run
        response
      when FileEventType::Deleted
        PublishDiagnostic.new(@workspace, text_document.uri).clean
      when FileEventType::Changed
        analyzer = Analyzer.new(@workspace, text_document)
        response = analyzer.run
        response
      end
    end

    private def dispatchNotification(params : Trace, msg)
      nil
    end

    # Used by:
    # - `handle_file_event`
    # - `DidOpenTextDocumentParams`
    # - `DidChangeTextDocumentParams`
    private def dispatchNotification(params : PublishDiagnosticsParams, msg)
      nil
    end
  end
end
