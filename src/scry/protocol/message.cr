require "json"
require "./did_change_configuration_params"

module Scry

  struct RequestMessageNoParams
    JSON.mapping({
      jsonrpc: String,
      id: Int32,
      method: String
    }, true)
  end

  struct RequestMessage
    JSON.mapping({
      jsonrpc: String,
      id: Int32,
      method: String,
      params: InitializeParams
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
        DidChangeWatchedFilesParams
      )
    }, true)
  end

  class InvalidContentError < Exception; end

  MessageType = RequestMessage | NotificationMessage | RequestMessageNoParams

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
