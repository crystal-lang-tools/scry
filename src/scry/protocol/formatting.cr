
module Scry
  class Formatter
    private getter text_document : TextDocument

    def initialize(@text_document)
    end

    def run
      format(text)
    end

    private def format(some_text)
      result = Crystal.format(some_text[0])
      formatted(result)
    # rescue ex : Crystal::Exception
    #   to_diagnostics(ex)
    end

    private def formatted(result)
      PublishFormatNotification.new(id, result)
    end

    private def to_diagnostics(ex)
      build_failures = Array(BuildFailure).from_json(ex.to_json)
      build_failures
        .uniq
        .first(20)
        .map { |bf| Diagnostic.new(bf) }
        .group_by { |diag| diag.uri }
        .map { |file, diagnostics|
        PublishDiagnosticsNotification.new(file, diagnostics)
      }
    end

    private def filename
      text_document.filename
    end

    private def text
      text_document.text
    end

    private def uri
      text_document.uri
    end

    private def id
      text_document.id
    end
  end
end
