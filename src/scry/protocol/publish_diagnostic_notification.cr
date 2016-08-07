require "json"
require "./notification"
require "../workspace"

module Scry

  struct PublishDiagnosticsNotification

    @uri : String
    @diagnostics : Array(Workspace::Diagnostic)

    private property :uri
    private property :diagnostics

    def initialize(@uri, @diagnostics)
    end

    def to_json(io)
      Notification
        .new("textDocument/publishDiagnostics")
        .compose_json(io) { |object|
          object.field "uri", uri
          object.field "diagnostics", diagnostics
        }
    end

    def to_json
      String.build { |io| to_json(io) }
    end

  end
end
