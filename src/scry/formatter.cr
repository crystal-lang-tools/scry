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
        line_counter = 0
        new_lines = result.split('\n')
        text_edits = new_lines.map do |line|
          range = Range.new(
            Position.new(line_counter, 0),
            Position.new(line_counter, result.size) # => Max column posible to replace old column
          )
          line_counter += 1
          TextEdit.new(range, line)
        end
        ResponseMessage.new(@text_document.id, text_edits)
      end
    end
  end
end
