require "json"
require "./workspace"
require "./update_config"
require "./analyzer"
require "./initialize"

module Scry

  class UnrecognizedProcedureError < Exception; end

  class InvalidRequestError < Exception; end

  class Context

    private property! workspace : Workspace

    def dispatch(msg : Scry::RequestMessageNoParams)
      case msg.method
      when "shutdown"
        # TODO: Perform shutdown and respond

      end
    end

    def dispatch(msg : RequestMessage)
      dispatchRequest(msg.params, msg)
    end

    def dispatch(msg : NotificationMessage)
      dispatchNotification(msg.params, msg)
    end

    private def dispatchRequest(params : InitializeParams, msg)
      initializer = Initialize.new(params, msg.id)
      @workspace, response = initializer.run
      response
    end

    private def dispatchNotification(params : DidChangeConfigurationParams, msg)
      updater = UpdateConfig.new(workspace, params)
      @workspace, response = updater.run
      response
    end

    private def dispatchNotification(params : DidOpenTextDocumentParams, msg)
      text_document = TextDocument.new(params)

      unless text_document.in_memory?
        analyzer = Analyzer.new(workspace, text_document)
        response = analyzer.run
        response
      end
    end

    private def dispatchNotification(params : DidChangeTextDocumentParams, msg)
      text_document = TextDocument.new(params)
      analyzer = ParseAnalyzer.new(workspace, text_document)
      response = analyzer.run
      response
    end

    private def dispatchNotification(params : DidChangeWatchedFilesParams, msg)
      params.changes.map { |file_event|
        handle_file_event(file_event)
      }.compact
    end

    private def dispatchNotification(params : DidOpOnTextDocumentParams, msg)
      text_document = TextDocument.new(params)

      case msg.method

      when "textDocument/didSave"
        nil

      when "textDocument/didClose"
        nil

      else
        raise UnrecognizedProcedureError.new(
          "Didn't recognize procedure: #{msg.method}"
        )
      end
    end

    private def handle_file_event(file_event : FileEvent)
      text_document = TextDocument.new(file_event)

      case file_event.type

      when FileEventType::Created
        analyzer = Analyzer.new(workspace, text_document)
        response = analyzer.run
        response

      when FileEventType::Deleted
        PublishDiagnosticsNotification.empty(text_document.uri)

      when FileEventType::Changed
        analyzer = Analyzer.new(workspace, text_document)
        response = analyzer.run
        response

      end

    end

  end

end
