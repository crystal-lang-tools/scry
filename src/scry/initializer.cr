require "./log"
require "./workspace"

module Scry
  struct Initializer
    def initialize(params : LSP::Protocol::InitializeParams, @msg_id : Int32)
      @workspace = Workspace.new(
        root_uri: params.root_path || params.root_uri.to_s.sub("file://", ""),
        process_id: params.process_id,
        max_number_of_problems: 100
      )
      ENV["CRYSTAL_PATH"] = %(#{@workspace.root_uri}/lib:#{ENV["CRYSTAL_PATH"]})
    end

    def run
      @workspace.open_workspace
      {@workspace, response}
    end

    def server_capabilities
      LSP::Protocol::ServerCapabilities.new(
        textDocumentSync: LSP::Protocol::TextDocumentSyncKind::Full, documentFormattingProvider: true,
        definitionProvider: true, documentSymbolProvider: true, workspaceSymbolProvider: true,
        completionProvider: LSP::Protocol::CompletionOptions.new, hoverProvider: true
      )
    end

    private def response
      LSP::Protocol::Initialize.new(@msg_id, server_capabilities)
    end
  end
end
