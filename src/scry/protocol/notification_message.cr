module Scry::Protocol
  alias NotificationType = (DidChangeConfigurationParams |
                            DidChangeTextDocumentParams |
                            DidChangeWatchedFilesParams |
                            DidOpenTextDocumentParams |
                            TextDocumentParams |
                            PublishDiagnosticsParams |
                            VoidParams |
                            CancelParams |
                            LogMessageParams |
                            Trace)

  struct NotificationMessage
    JSON.mapping({
      jsonrpc: String,
      method:  String,
      params:  NotificationType,
    }, true)

    @jsonrpc = "2.0"

    def initialize(@method, @params)
    end
  end
end
