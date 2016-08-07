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

    def dispatch(rpc : Scry::RemoteProcedureCall)
      case rpc.method
      when "initialize"
        initializer = Initialize.new(rpc.params)
        @workspace, response = initializer.run

        response

      else
        raise UnrecognizedProcedureError.new(rpc.method)
      end
    end

    def dispatch(notification : NotificationEvent)
      case notification.method
      when "workspace/didChangeConfiguration"
        updater = UpdateConfig.new(workspace, notification.params)
        @workspace, response = updater.run

        response

      when "textDocument/didOpen"
        analyzer = Analyzer.new(workspace, notification.params)
        @workspace, response = analyzer.run

        response

      when "textDocument/didChange"
        #TODO: parse changes and return warning diagnostics
        nil

      when "textDocument/didSave"
        #TODO: read file contents and analyzer
        nil

      when "workspace/didChangeWatchedFiles"
        #TODO: handle created, update, and deleted files
        nil

      when "textDocument/didClose"
        #TODO: handle closing a document
        nil

      else
        raise UnrecognizedProcedureError.new(
          "Unrecognized procedure: #{notification.method}"
        )
      end
    end

  end

end
