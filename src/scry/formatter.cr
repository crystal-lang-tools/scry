require "compiler/crystal/formatter"

require "./workspace"
require "./text_document"

module Scry
  struct Formatter
    def initialize(@workspace : Workspace, @text_document : TextDocument)
    end

    # NOTE: Some clients don't support newText bigger that 10000 characters.
    def run
      format(@text_document.text.first)
    end

    private def format(source)
      result = Crystal.format(source)
      unless source == result
        old_lines = source.split('\n')
        max_size = [source.size, result.size].max # => max amount of characters

        range = LSP::Protocol::Range.new(
          LSP::Protocol::Position.new(0, 0),
          LSP::Protocol::Position.new(old_lines.size, max_size) # => Max column posible to replace old column
        )

        LSP::Protocol::ResponseMessage.new(@text_document.id, [LSP::Protocol::TextEdit.new(range, result)])
      end
    rescue ex
      Log.error { "A error was found while formatting\n#{ex}\n#{result}" }
      nil
    end
  end
end
