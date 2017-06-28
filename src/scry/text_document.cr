module Scry

  class TextDocument

    getter uri : String
    getter text : Array(String)
    getter filename : String
    getter id : Int32 = 0

    def initialize(params : DidOpenTextDocumentParams)
      @uri = params.text_document.uri
      @filename = @uri.sub(/^file:\/\/|^inmemory:\/\//, "")
      @text = [params.text_document.text]
    end

    def initialize(params : DidOpOnTextDocumentParams)
      @uri = params.text_document.uri
      @filename = @uri.sub(/^file:\/\/|^inmemory:\/\//, "")
      @text = [read_file]
    end

    def initialize(file_event : FileEvent)
      @uri = file_event.uri
      @filename = @uri.sub(/^file:\/\/|^inmemory:\/\//, "")
      @text = [read_file]
    end

    def initialize(change : DidChangeTextDocumentParams)
      @uri = change.text_document.uri
      @filename = @uri.sub(/^file:\/\/|^inmemory:\/\//, "")
      @text = change.content_changes.map { |change| change.text }
    end

    def initialize(@uri, @text)
      @filename = @uri.sub(/^file:\/\/|^inmemory:\/\//, "")
    end

    def initialize(format : FormattingMessage)
      @uri = format.params.text_document.uri
      @id = format.id
      @filename = @uri.sub(/^file:\/\/|^inmemory:\/\//, "")
      @text = [read_file]
    end

    def in_memory?
      uri.starts_with?("inmemory://")
    end

    private def read_file : String
      File.read(filename)
    rescue ex : IO::Error
      Log.logger.warn ex.message
      ""
    rescue ex : Errno
      Log.logger.warn ex.message
      ""
    end


  end

end
