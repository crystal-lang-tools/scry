require "uri"
require "./protocol/*"
require "compiler/crystal/**"

module Scry

  class Workspace
    private getter :root_path
    private getter :process_id

    def initialize(params)
      @root_path = params.root_path as String
      @process_id = params.process_id as Int64
      @max_number_of_problems = uninitialized Int32
    end

    def config_changed(params : DidChangeConfigurationParams)
      @max_number_of_problems =
        params.settings.crystalIDE.max_number_of_problems
    end

    def config_changed(params)
      raise "Unexpected configuration: #{params}"
    end

    def analyze(doc : TextDocument)
      source = Crystal::Compiler::Source.new(
        doc.text_document.uri.sub("file://", ""),
        doc.text_document.text
      )
      compiler = Crystal::Compiler.new
      compiler.color = false
      compiler.no_codegen = true
      compiler.compile source, source.filename + ".out"
      nil
    rescue ex : Crystal::Exception
      to_diagnostics(ex)
    end

    def analyze(whatever)
      raise "Can't analyze: #{whatever}"
    end

    private def settings=(settings)
      @max_number_of_problems = settings.max_number_of_problems
    end

    private def to_diagnostics(ex)
      build_failures = Array(BuildFailure).from_json(to_json(ex))
      build_failures
        .map { |bf| Diagnostic.new(bf) }
        .group_by { |diag| diag.uri }
        .map { |file, diagnostics|
          PublishDiagnosticsNotification.new(file, diagnostics)
        }
    end

    private def to_json(ex)
      String.build { |io| ex.to_json(io) }
    end

    struct BuildFailure
      JSON.mapping(
        file: String,
        line: Int32,
        column: Int32,
        size: Int32,
        message: String
      )
    end

    class Diagnostic

      @bf : BuildFailure

      def initialize(bf : BuildFailure)
        @bf = bf
      end

      def filename
        @bf.file
      end

      def uri
        "file://#{filename}"
      end

      def to_json
        String.build { |io| to_json(io) }
      end

      def to_json(io)
        io.json_object do |object|
          object.field "range" do
            io.json_object do |range|
              range.field "start" do
                io.json_object do |pos|
                  pos.field "line", @bf.line - 1
                  pos.field "character", @bf.column - 1
                end
              end
              range.field "end" do
                io.json_object do |pos|
                  pos.field "line", @bf.line
                  pos.field "character", @bf.column + @bf.size - 1
                end
              end
            end
          end
          object.field "severity", 1 # Right now, everything is an error
          object.field "source", "Scry [Crystal]"
          object.field "message", @bf.message
        end
      end

    end

  end

end
