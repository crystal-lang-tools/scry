require "json"
require "./workspace"
require "./commands/*"

module Scry

  class UnrecognizedProcedureError < Exception; end

  class InvalidRequestError < Exception; end

  class Context

    private property! workspace : Workspace

    def dispatch(rpc : Scry::RemoteProcedureCallNoParams)
      case rpc.method
      when "shutdown"
        # TODO: Perform shutdown and respond
        ""

      else
        raise UnrecognizedProcedureError.new(rpc.method)
      end
    end

    def dispatch(rpc : Scry::RemoteProcedureCall | Scry::NotificationEvent)
      dispatch(rpc.params, rpc.method)
    end

    def dispatch(params : InitializeParams, method_name)
      initializer = Initialize.new(params)
      @workspace, response = initializer.run
      response
    end

    def dispatch(params : DidChangeConfigurationParams, method_name)
      updater = UpdateConfig.new(workspace, params)
      @workspace, response = updater.run
      response
    end

    def dispatch(params : DidOpenTextDocumentParams, method_name)
      analyzer = Analyzer.new(workspace, params)
      @workspace, response = analyzer.run
      response
    end

    def dispatch(params : DidChangeTextDocumentParams, method_name)
      # TODO: parse changes and return warning diagnostics
      nil
    end

    def dispatch(params : DidChangeWatchedFilesParams, method_name)
      #TODO: handle created, update, and deleted files
      nil
    end

    def dispatch(params : DidOpOnTextDocumentParams, method_name)
      case method_name

      when "textDocument/didSave"
        analyzer = Analyzer.new(workspace, params)
        @workspace, response = analyzer.run
        response

      when "textDocument/didClose"
        #TODO: handle closing a document
        nil

      else
        raise UnrecognizedProcedureError.new(
          "Didn't recognize procedures: #{method_name}"
        )
      end
    end

  end

end
