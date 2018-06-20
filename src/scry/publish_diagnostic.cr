require "./protocol/publish_diagnostics_params"
require "./protocol/notification_message"
require "./protocol/diagnostic"
require "./build_failure"
require "./workspace"

module Scry
  struct PublishDiagnostic
    # Store all groups of files that have received some diagnostic,
    # Useful to clean diagnostics after code changes.
    # Each group depends on the file that generated the diagnostic
    # and can be cleared just by that file.
    ALL_FILES_WITH_DIAGNOSTIC = {} of String => Array(String)

    def initialize(@workspace : Workspace, @uri : String)
      ALL_FILES_WITH_DIAGNOSTIC[@uri] = [] of String
    end

    private def notification(params)
      NotificationMessage.new("textDocument/publishDiagnostics", params)
    end

    private def unclean(file, diagnostics)
      params = PublishDiagnosticsParams.new(file, diagnostics)
      notification(params)
    end

    # Reset all diagnostics in the current project
    # If the computed set is empty it has to push the empty array to clear former diagnostic
    # See: https://microsoft.github.io/language-server-protocol/specification#textDocument_publishDiagnostics
    def full_clean
      clean_diagnostics = ALL_FILES_WITH_DIAGNOSTIC[@uri].map do |file|
        clean(file)
      end
      ALL_FILES_WITH_DIAGNOSTIC[@uri].clear
      clean_diagnostics << clean if clean_diagnostics.empty?
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
        .select { |file, diagnostics| !file.ends_with?(".scry_main.cr") }
        .map do |file, diagnostics|
          ALL_FILES_WITH_DIAGNOSTIC[@uri] << file
          unclean(file, diagnostics)
        end
    end
  end
end
