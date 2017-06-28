require "json"
require "./did_change_configuration_params"
require "./did_open_text_document_params"
require "./did_change_text_document_params"
require "./did_op_on_text_document_params"
require "./did_change_watched_files_params"
require "./initialize_params"

module Scry

  struct RequestMessageNoParams
    JSON.mapping({
      jsonrpc: String,
      id: Int32,
      method: String,
      params: Nil?
    })
  end

  struct RequestMessage
    JSON.mapping({
      jsonrpc: String,
      id: Int32,
      method: String,
      params: InitializeParams
    }, true)
  end

  struct Trace
    JSON.mapping(
      value: String
    )
  end

  struct DocumentOptions
    JSON.mapping({
      tabSize: Int32,
      insertSpaces: Bool
    }, true)
  end

  struct FormattingParams
    JSON.mapping({
      text_document: { type: TextDocumentIdentifier, key: "textDocument" },
      options: DocumentOptions
    }, true)
  end

  struct FormattingMessage
    JSON.mapping({
      jsonrpc: String,
      id: Int32,
      method: String,
      params: FormattingParams
    }, true)
  end

  struct NotificationMessage
    JSON.mapping({
      jsonrpc: String,
      method: String,
      params: (
        DidChangeConfigurationParams |
        DidOpenTextDocumentParams |
        DidChangeTextDocumentParams |
        DidOpOnTextDocumentParams |
        DidChangeWatchedFilesParams |
        Trace
      )
    }, true)
  end

  class InvalidContentError < Exception; end

  MessageType = RequestMessage | NotificationMessage | RequestMessageNoParams | FormattingMessage

  struct Message

    def initialize(@json : String)
    end

    def initialize(@json : Nil)
      raise InvalidContentError.new("Expected procedure content")
    end

    def parse
      MessageType.from_json(@json || "")
    end

  end

end
