require "json"
require "./notification"
require "./diagnostic"

module Scry
  struct PublishDiagnosticsNotification < Notification
    @uri : String
    @diagnostics : Array(Diagnostic)

    private property :uri
    private property :diagnostics

    def self.empty(uri)
      new(uri, [] of Diagnostic)
    end

    def initialize(@uri, @diagnostics)
      super("textDocument/publishDiagnostics", @uri, @diagnostics)
    end

    def empty?
      diagnostics.empty?
    end
  end
end
