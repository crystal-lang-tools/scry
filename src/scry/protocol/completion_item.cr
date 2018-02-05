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
      documentation: {type: String, nilable: true}, #  | Markup
      sortText:      String,
      filterText:    String,
      insertText:    String,
      # command: Command,
      data: {type: JSON::Any, nilable: true}
      # insertTestFormat: String,
      # textEdit: TextEdit,
      # additionalTextEdits:  Array(TextEdit),
      # commitCharacters: Array(String)
    }, true)
    def initialize(@label, @kind, @detail, @data = nil, @documentation = nil)
      @sortText = @label
      @filterText = @label
      @insertText = @label
    end
  end
end