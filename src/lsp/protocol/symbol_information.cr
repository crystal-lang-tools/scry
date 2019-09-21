module LSP::Protocol
  enum SymbolKind
    File        =  1
    Module      =  2
    Namespace   =  3
    Package     =  4
    Class       =  5
    Method      =  6
    Property    =  7
    Field       =  8
    Constructor =  9
    Enum        = 10
    Interface   = 11
    Function    = 12
    Variable    = 13
    Constant    = 14
    String      = 15
    Number      = 16
    Boolean     = 17
    Array       = 18
  end

  struct SymbolInformation
    JSON.mapping({
      name:          String,
      kind:          SymbolKind,
      location:      Location,
      containerName: String?,
    }, true)

    def initialize(@name, @kind, @location, @containerName = Nil)
    end
  end
end
