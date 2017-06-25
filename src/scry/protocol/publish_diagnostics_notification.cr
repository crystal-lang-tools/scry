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

    # def to_json
    #   Notification
    #     .new("textDocument/publishDiagnostics")
    #     .compose_json {
    #     JSON.build do |json|
    #       json.object do
    #         json.field "uri", uri
    #         json.field "diagnostics" do
    #           json.array do
    #             diagnostics.each do |diag|
    #               json.raw diag.to_json
    #             end
    #           end
    #         end
    #       end
    #     end
    #   }
    # end

    # def to_json
    #   String.build { |io| to_json(io) }
    # end

    def empty?
      diagnostics.empty?
    end
  end
end
