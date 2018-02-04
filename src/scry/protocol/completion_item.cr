module Scry
  enum CompletionItemKind
    Text          =  1
    Method        =  2
    Function      =  3
    Constructor   =  4
    Field         =  5
    Variable      =  6
    Class         =  7
    Interface     =  8
    Module        =  9
    Property      = 10
    Unit          = 11
    Value         = 12
    Enum          = 13
    Keyword       = 14
    Snippet       = 15
    Color         = 16
    File          = 17
    Reference     = 18
    Folder        = 19
    EnumMember    = 20
    Constant      = 21
    Struct        = 22
    Event         = 23
    Operator      = 24
    TypeParameter = 25
  end

  struct CompletionItem
    JSON.mapping({
      label:         String,
      kind:          CompletionItemKind,
      detail:        String,
      # documentation: String, #  | Markup
      sortText:      String,
      filterText:    String,
      insertText:    String
      # command: Command,
      # data: JSON::Any,
      # insertTestFormat: String,
      # textEdit: TextEdit,
      # additionalTextEdits:  Array(TextEdit),
      # commitCharacters: Array(String)
    }, true)
    def initialize(@label, @kind, @detail)
      @sortText = @label
      @filterText = @label
      @insertText = @label
    end
  end
end

# /**
#  * Represents a collection of [completion items](#CompletionItem) to be presented
#  * in the editor.
#  */
# interface CompletionList {
# 	/**
# 	 * This list it not complete. Further typing should result in recomputing
# 	 * this list.
# 	 */
# 	isIncomplete: boolean;

# 	/**
# 	 * The completion items.
# 	 */
# 	items: CompletionItem[];
# }

# /**
#  * Defines whether the insert text in a completion item should be interpreted as
#  * plain text or a snippet.
#  */
# namespace InsertTextFormat {
# 	/**
# 	 * The primary text to be inserted is treated as a plain string.
# 	 */
# 	export const PlainText = 1;

# 	/**
# 	 * The primary text to be inserted is treated as a snippet.
# 	 *
# 	 * A snippet can define tab stops and placeholders with `$1`, `$2`
# 	 * and `${3:foo}`. `$0` defines the final tab stop, it defaults to
# 	 * the end of the snippet. Placeholders with equal identifiers are linked,
# 	 * that is typing in one will update others too.
# 	 */
# 	export const Snippet = 2;
# }

# type InsertTextFormat = 1 | 2;
