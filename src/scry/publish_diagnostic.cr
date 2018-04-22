require "./protocol/publish_diagnostics_params"
require "./protocol/notification_message"
require "./protocol/diagnostic"
require "./build_failure"
require "./workspace"

module Scry
  struct PublishDiagnostic
    METHOD = "textDocument/publishDiagnostics"
    FILES_WITH_DIAGNOSTIC = [] of String

    def initialize(@workspace : Workspace, @uri : String)
    end

    private def notification(params)
      NotificationMessage.new(METHOD, params)
    end

    private def unclean(file, diagnostics)
      params = PublishDiagnosticsParams.new(file, diagnostics)
      notification(params)
    end

    # Reset all diagnostics in the current project
    # If the computed set is empty it has to push the empty array to clear former diagnostic
    # See: https://microsoft.github.io/language-server-protocol/specification#textDocument_publishDiagnostics
    def full_clean
      clean_diagnostics = FILES_WITH_DIAGNOSTIC.map do |file|
        clean(file)
      end
      FILES_WITH_DIAGNOSTIC.clear
      clean_diagnostics
    end

    def clean(uri = @uri)
      params = PublishDiagnosticsParams.new(uri, [] of Diagnostic)
      notification(params)
    end

    def from(ex) : Array(NotificationMessage)
      build_failures = Array(BuildFailure).from_json(ex)
      build_failures
        .uniq
        .first(@workspace.max_number_of_problems)
        .map { |bf| Diagnostic.new(bf) }
        .group_by(&.uri)
        .select { |file, diagnostics| !file.ends_with?(".scry.cr") }
        .map do |file, diagnostics|
          FILES_WITH_DIAGNOSTIC << file
          unclean(file, diagnostics)
        end
    end
  end
end
