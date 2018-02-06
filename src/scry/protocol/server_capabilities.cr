require "json"

module Scry
  enum TextDocumentSyncKind
    None
    Full
    Incremental
  end
  struct CompletionOptions
    JSON.mapping(
      resolveProvider: Bool,
      triggerCharacters: Array(String)
    )
    def initialize
      @resolveProvider = true
      @triggerCharacters = [".", "\"", "/"]
    end
  end

  # Specify Sever capabilities supported,
  # Currently Crystal supports:
  #
  # - Go to definition or Implementation (WIP)
  # - Diagnostics (WIP)
  # - Formatting (WIP)
  # - Symbols https://github.com/crystal-lang/crystal/blob/1f3e8b0e742b55c1feb5584dc932e87034365f48/samples/compiler/visitor_example.cr
  # - Rename https://github.com/crystal-lang/crystal/blob/1f3e8b0e742b55c1feb5584dc932e87034365f48/samples/compiler/transformer_example.cr
  # - Completion https://github.com/TechMagister/cracker
  # - Hover
  # - Code Actions
  # - Signature Help
  # - Range Formatting
  #
  # Features not supported by Crystal yet:
  #
  # - CodeLens
  # - Find References
  #
  # To enable more capabilities, See: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md
  struct ServerCapabilities
    JSON.mapping(
      textDocumentSync: TextDocumentSyncKind,
      documentFormattingProvider: Bool,
      definitionProvider: Bool,
      documentSymbolProvider: Bool,
      completionProvider: CompletionOptions
    )

    def initialize
      @textDocumentSync = TextDocumentSyncKind::Full
      @documentFormattingProvider = true
      @definitionProvider = true
      @documentSymbolProvider = true
      @completionProvider = CompletionOptions.new
    end
  end
end
