module Scry
  struct TextDocument
    getter id : Int32 | Nil
    getter uri : String
    getter filename : String
    getter position : Protocol::Position?
    property text : Array(String)

    def initialize(@uri, @text)
      @filename = uri_to_filename
    end

    def initialize(@uri)
      @filename = uri_to_filename
      @text = [read_file]
    end

    def initialize(params : Protocol::DidOpenTextDocumentParams)
      @uri = params.text_document.uri
      @filename = uri_to_filename
      @text = [params.text_document.text]
    end

    # Used by ParseAnalyzer
    def initialize(change : Protocol::DidChangeTextDocumentParams)
      @uri = change.text_document.uri
      @filename = uri_to_filename
      @text = change.content_changes.map { |change| change.text }
    end

    # Used by Analyzer
    def initialize(file_event : Protocol::FileEvent)
      @uri = file_event.uri
      @filename = uri_to_filename
      @text = [read_file]
    end

    def initialize(params : Protocol::DocumentFormattingParams, @id)
      @uri = params.text_document.uri
      @filename = uri_to_filename
      @text = [""]
    end

    def initialize(params : Protocol::TextDocumentPositionParams, @id)
      @uri = params.text_document.uri
      @position = params.position
      @filename = uri_to_filename
      @text = [read_file]
    end

    def initialize(params : Protocol::TextDocumentParams, @id = nil)
      @uri = params.text_document.uri
      @filename = uri_to_filename
      @text = [read_file]
    end

    def uri_to_filename
      @uri.sub(/^file:\/\/|^inmemory:\/\/|^git:\/\//, "")
    end

    def in_memory?
      uri.starts_with?("inmemory://") || uri.starts_with?("git://")
    end

    def untitled?
      uri.starts_with?("untitled:")
    end

    def inside_crystal_path?
      ENV["CRYSTAL_PATH"].split(':').each do |path|
        return true if filename.starts_with?(path)
      end
      false
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
