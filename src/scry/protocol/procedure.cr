require "json"

module Scry



  struct RemoteProcedureCall
    JSON.mapping({
      jsonrpc: String,
      id: Int32,
      method: String,
      params: InitializeParams
    }, true)
  end

  struct NotificationEvent
    JSON.mapping({
      jsonrpc: String,
      method: String,
      params: DidChangeConfigurationParams | TextDocument
    }, true)
  end

  class InvalidContentError < Exception; end

  ProcedureType = RemoteProcedureCall | NotificationEvent

  struct Procedure

    def initialize(@json : String)
    end

    def initialize(@json : Nil)
      raise InvalidContentError.new("Expected procedure content")
    end

    def parse
      ProcedureType.from_json(@json || "")
    end

  end

end