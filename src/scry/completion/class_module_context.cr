require "./context"

module Scry::Completion
  class ClassModuleContext < Context
    def initialize(@text : String, @target : String, @method_db : Completion::MethodDB)
    end

    def find
      target_header_index = @target.rindex(":")
      @method_db.type_match(@target).map do |label|
        if target_header_index
          label = label[(target_header_index + 1)..-1]
        end

        CompletionItem.new(
          label: label,
          insert_text: label,
          kind: CompletionItemKind::Class,
          detail: label,
          data: nil
        )
      end
    end
  end
end
