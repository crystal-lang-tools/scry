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
require "./hover_provider"

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
    def dispatch(msg : Protocol::RequestMessage)
      Log.logger.debug(msg.method)
      dispatch_request(msg.params, msg)
    end

    def dispatch(msg : Protocol::NotificationMessage)
      Log.logger.debug(msg.method)
      dispatch_notification(msg.params, msg)
    end

    private def dispatch_request(params : Nil, msg)
      if msg.method == "shutdown"
        Scry.shutdown = true
        Protocol::ResponseMessage.new(msg.id, nil)
      end
    end

    private def dispatch_notification(params : Nil, msg)
      if msg.method == "exit"
        exit(0)
      end
    end

    private def dispatch_request(params : Protocol::InitializeParams, msg)
      initializer = Initializer.new(params, msg.id)
      @workspace, response = initializer.run
      response
    end

    # Also used by methods like Go to Definition
    private def dispatch_request(params : Protocol::TextDocumentPositionParams, msg)
      case msg.method
      when "textDocument/hover"
        text_document = TextDocument.new(params, msg.id)
		if text_document.should_be_ignored?
			Log.logger.debug("Ignoring path: #{text_document.filename}")
			return nil
		end
        hover = HoverProvider.new(@workspace, text_document)
        response = hover.run
        Log.logger.debug(response)
        response
      when "textDocument/definition"
        text_document = TextDocument.new(params, msg.id)
		if text_document.should_be_ignored?
			Log.logger.debug("Ignoring path: #{text_document.filename}")
			return nil
		end
        definitions = Implementations.new(@workspace, text_document)
        response = definitions.run
        Log.logger.debug(response)
        response
      when "textDocument/completion"
        text_document, method_db = @workspace.get_file(TextDocument.uri_to_filename(params.text_document.uri))
		if text_document.should_be_ignored?
			Log.logger.debug("Ignoring path: #{text_document.filename}")
			return nil
		end
        completion = CompletionProvider.new(text_document, params.context, params.position, method_db)
        results = completion.run
        response = Protocol::ResponseMessage.new(msg.id, results)
        Log.logger.debug(response)
        response
      else
        raise UnrecognizedProcedureError.new("Didn't recognize procedure: #{msg.method}")
      end
    end

    private def dispatch_request(params : Protocol::DocumentFormattingParams, msg)
      text_document = TextDocument.new(params, msg.id)

      if open_file = @workspace.open_files[text_document.filename]?
        text_document.text = open_file.first.text
      end

      formatter = Formatter.new(@workspace, text_document)
      response = formatter.run
      Log.logger.debug(response)
      response
    end

    private def dispatch_request(params : Protocol::TextDocumentParams, msg)
      case msg.method
      when "textDocument/documentSymbol"
        text_document = TextDocument.new(params, msg.id)
		if text_document.should_be_ignored?
			Log.logger.debug("Ignoring path: #{text_document.filename}")
			return nil
		end
        symbol_processor = SymbolProcessor.new(text_document)
        symbols = symbol_processor.run
        response = Protocol::ResponseMessage.new(msg.id, symbols)
        Log.logger.debug(response)
        response
      end
    end

    private def dispatch_request(params : Protocol::WorkspaceSymbolParams, msg)
      case msg.method
      when "workspace/symbol"
        workspace_symbol_processor = WorkspaceSymbolProcessor.new(@workspace.root_uri, params.query)
        symbols = workspace_symbol_processor.run
        response = Protocol::ResponseMessage.new(msg.id, symbols)
        Log.logger.debug(response)
        response
      end
    end

    private def dispatch_request(params : Protocol::CompletionItem, msg)
      case msg.method
      when "completionItem/resolve"
        resolver = CompletionResolver.new(msg.id, params)
        results = resolver.run
        response = Protocol::ResponseMessage.new(msg.id, results)
        Log.logger.debug(response)
        response
      end
    end

    # Used by:
    # - `textDocument/didSave`
    # - `textDocument/didClose`
    private def dispatch_notification(params : Protocol::TextDocumentParams, msg)
      case msg.method
      when "textDocument/didClose"
        @workspace.drop_file(TextDocument.new(params))
      end
      nil
    end

    private def dispatch_notification(params : Protocol::DidChangeConfigurationParams, msg)
      updater = UpdateConfig.new(@workspace, params)
      @workspace, response = updater.run
      response
    end

    private def dispatch_notification(params : Protocol::DidOpenTextDocumentParams, msg)
      text_document = TextDocument.new(params)
      @workspace.put_file(text_document)
	  unless text_document.in_memory? || text_document.should_be_ignored?
        analyzer = Analyzer.new(@workspace, text_document)
        response = analyzer.run
        response
      end
    end

    private def dispatch_notification(params : Protocol::DidChangeTextDocumentParams, msg)
      text_document = TextDocument.new(params)
      @workspace.update_file(text_document)
      analyzer = ParseAnalyzer.new(@workspace, text_document)
      response = analyzer.run
      response
    end

    private def dispatch_notification(params : Protocol::DidChangeWatchedFilesParams, msg)
      params.changes.map { |file_event|
        handle_file_event(file_event)
      }.compact
    end

    private def handle_file_event(file_event : Protocol::FileEvent)
      text_document = TextDocument.new(file_event)

      case file_event.type
      when Protocol::FileEventType::Created
        analyzer = Analyzer.new(@workspace, text_document)
        response = analyzer.run
        response
      when Protocol::FileEventType::Deleted
        PublishDiagnostic.new(@workspace, text_document.uri).full_clean
      when Protocol::FileEventType::Changed
        @workspace.reopen_workspace(text_document)
        analyzer = Analyzer.new(@workspace, text_document)
        response = analyzer.run
        response
      end
    end

    private def dispatch_notification(params, msg)
      nil
    end
  end
end
