require "./protocol/file_event"
require "./protocol/document_formatting_params"
require "./protocol/did_open_text_document_params"
require "./protocol/did_change_text_document_params"
require "./protocol/did_change_watched_files_params"
require "./protocol/did_change_configuration_params"

module Scry
  struct TextDocument
    getter id : Int32 | Nil
    getter uri : String
    getter filename : String
    getter position : Position?
    property text : Array(String)

    def initialize(@uri, @text)
      @filename = uri_to_filename
    end

    def initialize(params : DidOpenTextDocumentParams)
      @uri = params.text_document.uri
      @filename = uri_to_filename
      @text = [params.text_document.text]
    end

    # Used by ParseAnalyzer
    def initialize(change : DidChangeTextDocumentParams)
      @uri = change.text_document.uri
      @filename = uri_to_filename
      @text = change.content_changes.map { |change| change.text }
    end

    # Used by Analyzer
    def initialize(file_event : FileEvent)
      @uri = file_event.uri
      @filename = uri_to_filename
      @text = [read_file]
    end

    def initialize(params : DocumentFormattingParams, @id)
      @uri = params.text_document.uri
      @filename = uri_to_filename
      if untitled?
        @text = [""]
      else
        @text = [read_file]
      end
    end

    def initialize(params : TextDocumentPositionParams, @id)
      @uri = params.text_document.uri
      @position = params.position
      @filename = uri_to_filename
      @text = [read_file]
    end

    def initialize(params : TextDocumentParams, @id)
      @uri = params.text_document.uri
      @filename = uri_to_filename
      @text = [read_file]
    end

    def uri_to_filename
      self.class.uri_to_filename(@uri)
    end

    def self.uri_to_filename(uri)
      uri.sub(/^file:\/\/|^inmemory:\/\/|^git:\/\//, "")
    end

    def in_memory?
      uri.starts_with?("inmemory://") || uri.starts_with?("git://")
    end

    def untitled?
      uri.starts_with?("untitled:")
    end

    def source
      @text.first
    end

    private def read_file : String
      File.read(filename)
    rescue ex : IO::Error
      Log.logger.warn(ex.message)
      ""
    rescue ex : Errno
      Log.logger.warn(ex.message)
      ""
    end
  end
end
