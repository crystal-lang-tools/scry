require "./analyzer"
require "./workspace"
require "./formatter"
require "./initializer"
require "./implementations"
require "./update_config"
require "./parse_analyzer"
require "./publish_diagnostic"
require "./symbol"
require "./completion_provider"
require "./completion_resolver"

module Scry
  class_property shutdown = false

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
    def dispatch(msg : RequestMessage)
      Log.logger.debug(msg.method)
      dispatch_request(msg.params, msg)
    end

    def dispatch(msg : NotificationMessage)
      Log.logger.debug(msg.method)
      dispatch_notification(msg.params, msg)
    end

    private def dispatch_request(params : Nil, msg)
      if msg.method == "shutdown"
        Scry.shutdown = true
        ResponseMessage.new(msg.id, nil)
      end
    end

    private def dispatch_notification(params : Nil, msg)
      if msg.method == "exit"
        exit(0)
      end
    end

    private def dispatch_request(params : InitializeParams, msg)
      initializer = Initializer.new(params, msg.id)
      @workspace, response = initializer.run
      response
    end

    # Also used by methods like Go to Definition
    private def dispatch_request(params : TextDocumentPositionParams, msg)
      case msg.method
      when "textDocument/definition"
        text_document = TextDocument.new(params, msg.id)
        definitions = Implementations.new(@workspace, text_document)
        response = definitions.run
        Log.logger.debug(response)
        response
      when "textDocument/completion"
        text_document, method_db = @workspace.get_file(params.text_document)
        completion = CompletionProvider.new(text_document, params.context, params.position, method_db)
        results = completion.run
        response = ResponseMessage.new(msg.id, results)
        Log.logger.debug(response)
        response
      else
        raise UnrecognizedProcedureError.new("Didn't recognize procedure: #{msg.method}")
      end
    end

    private def dispatch_request(params : DocumentFormattingParams, msg)
      text_document = TextDocument.new(params, msg.id)

      if open_file = @workspace.open_files[text_document.filename]?
        text_document.text = open_file.first.text
      end

      formatter = Formatter.new(@workspace, text_document)
      response = formatter.run
      Log.logger.debug(response)
      response
    end

    private def dispatch_request(params : TextDocumentParams, msg)
      case msg.method
      when "textDocument/documentSymbol"
        text_document = TextDocument.new(params, msg.id)
        symbol_processor = SymbolProcessor.new(text_document)
        response = symbol_processor.run
        Log.logger.debug(response)
        response
      end
    end

    private def dispatch_request(params : WorkspaceSymbolParams, msg)
      case msg.method
      when "workspace/symbol"
        query = params.query
        root_path = TextDocument.uri_to_filename(@workspace.root_uri)
        workspace_symbol_processor = WorkspaceSymbolProcessor.new(msg.id, root_path, query)
        response = workspace_symbol_processor.run
        Log.logger.debug(response)
        response
      end
    end

    private def dispatch_request(params : CompletionItem, msg)
      case msg.method
      when "completionItem/resolve"
        resolver = CompletionResolver.new(msg.id, params)
        results = resolver.run
        response = ResponseMessage.new(msg.id, results)
        Log.logger.debug(response)
        response
      end
    end

    # Used by:
    # - $/cancelRequest
    private def dispatch_notification(params : CancelParams, msg)
      nil
    end

    # Used by:
    # - `textDocument/didSave`
    # - `textDocument/didClose`
    private def dispatch_notification(params : TextDocumentParams, msg)
      case msg.method
      when "textDocument/didClose"
        @workspace.drop_file(params)
      end
      nil
    end

    private def dispatch_notification(params : DidChangeConfigurationParams, msg)
      updater = UpdateConfig.new(@workspace, params)
      @workspace, response = updater.run
      response
    end

    private def dispatch_notification(params : DidOpenTextDocumentParams, msg)
      @workspace.put_file(params)
      text_document = TextDocument.new(params)
      unless text_document.in_memory?
        analyzer = Analyzer.new(@workspace, text_document)
        response = analyzer.run
        response
      end
    end

    private def dispatch_notification(params : DidChangeTextDocumentParams, msg)
      @workspace.update_file(params)
      text_document = TextDocument.new(params)
      analyzer = ParseAnalyzer.new(@workspace, text_document)
      response = analyzer.run
      response
    end

    private def dispatch_notification(params : DidChangeWatchedFilesParams, msg)
      params.changes.map { |file_event|
        handle_file_event(file_event)
      }.compact
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

    private def dispatch_notification(params : Trace, msg)
      nil
    end

    # Used by:
    # - `handle_file_event`
    # - `DidOpenTextDocumentParams`
    # - `DidChangeTextDocumentParams`
    private def dispatch_notification(params : PublishDiagnosticsParams, msg)
      nil
    end

    private def dispatch_notification(params : VoidParams, msg)
      nil
    end
  end
end
