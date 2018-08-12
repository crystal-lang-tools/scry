require "compiler/crystal/formatter"

require "./workspace"
require "./text_document"
require "./protocol/text_edit"
require "./protocol/response_message"

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

        range = Range.new(
          Position.new(0, 0),
          Position.new(old_lines.size, max_size) # => Max column posible to replace old column
        )

        ResponseMessage.new(@text_document.id, [TextEdit.new(range, result)])
      end
    rescue ex
      Log.logger.error("A error was found while formatting\n#{ex}\n#{result}")
      nil
    end
  end
end
