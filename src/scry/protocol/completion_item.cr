require "./markup_content"

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

  enum InsertTextFormat
    PlainText = 1
    Snippet   = 2
  end

  struct RequireModuleContextData
    JSON.mapping({
      require_module_context: Bool,
      path:                   String,
    })

    def initialize(@path)
      @require_module_context = true
    end
  end

  struct MethodCallContextData
    JSON.mapping({
      method_completion_context: Bool,
      path:                      String,
      location:                  String,
    })

    def initialize(@path, @location)
      @method_completion_context = true
    end
  end

  alias CompletionItemData = RequireModuleContextData | MethodCallContextData

  struct CompletionItem
    JSON.mapping({
      label:              String,
      kind:               CompletionItemKind,
      detail:             String,
      documentation:      {type: MarkupContent, nilable: true}, #  | Markup
      sort_text:          {type: String, key: "sortText"},
      filter_text:        {type: String, key: "filterText"},
      insert_text:        {type: String, key: "insertText"},
      insert_text_format: {type: InsertTextFormat, key: "insertTextFormat"},
      # command: Command,
      data: {type: CompletionItemData, nilable: true}, # insertTestFormat: String,
      # textEdit: TextEdit,
      # additionalTextEdits:  Array(TextEdit),
      # commitCharacters: Array(String)
    }, true)

    def initialize(@label, @kind, @detail, @data, insert_text = nil, @documentation = nil)
      @sort_text = @label
      @filter_text = @label
      @insert_text = insert_text || @label
      @insert_text_format = InsertTextFormat::PlainText
    end
  end
end
