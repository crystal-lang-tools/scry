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
        new_lines = result.split('\n')
        old_lines = source.split('\n')
        max_line_num = [old_lines.size, new_lines.size].max # => max amount of lines
        max_size = [source.size, result.size].max # => max amount of characters
        text_edits = new_lines.map_with_index do |line_data, line_num|
          # Ensure to replace all old document
          if line_num == new_lines.size - 1
            line_num_end = max_line_num
          else
            line_num_end = line_num
          end
          range = Range.new(
            Position.new(line_num, 0),
            Position.new(line_num_end, max_size) # => Max column posible to replace old column
          )
          TextEdit.new(range, line_data)
        end
        ResponseMessage.new(@text_document.id, text_edits)
      end
    end
  end
end
