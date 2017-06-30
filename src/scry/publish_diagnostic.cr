require "./protocol/publish_diagnostics_params"
require "./protocol/notification_message"
require "./protocol/diagnostic"
require "./build_failure"
require "./workspace"

module Scry
  struct PublishDiagnostic
    METHOD = "textDocument/publishDiagnostics"

    def initialize(@workspace : Workspace, @uri : String)
    end

    private def notification(params)
      NotificationMessage.new(METHOD, params)
    end

    private def unclean(file, diagnostics)
      params = PublishDiagnosticsParams.new(file, diagnostics)
      notification(params)
    end

    def clean
      params = PublishDiagnosticsParams.new(@uri, [] of Diagnostic)
      notification(params)
    end

    def from(ex)
      build_failures = Array(BuildFailure).from_json(ex.to_json)
      build_failures
        .uniq
        .first(@workspace.max_number_of_problems)
        .map { |bf| Diagnostic.new(bf) }
        .group_by(&.uri)
        .map { |file, diagnostics| unclean(file, diagnostics) }
    end
  end
end
