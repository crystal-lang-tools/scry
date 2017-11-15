require "compiler/crystal/syntax"

module Scry
  class SymbolVisitor < Crystal::Visitor
    getter symbols

    def initialize(@document_uri : String)
      @container = [] of String
      @symbols = [] of SymbolInformation
    end

    def visit(node : Crystal::ClassDef)
      process_node node, node.name.names.last, SymbolKind::Class
      @container << node.name.names.last
      true
    end

    def visit(node : Crystal::EnumDef)
      process_node node, node.name.names.last, SymbolKind::Enum
      @container << node.name.names.last
      true
    end

    def visit(node : Crystal::ModuleDef)
      process_node node, node.name.names.last, SymbolKind::Module
      @container << node.name.names.last
      true
    end

    def visit(node : Crystal::Def)
      process_node node, node.name, SymbolKind::Method
      false
    end

    def visit(node : Crystal::LibDef)
      process_node node, node.name, SymbolKind::Package
      @container << node.name
      true
    end

    def visit(node : Crystal::StructOrUnionDef)
      process_node node, node.name, SymbolKind::Class
      @container << node.name
      true
    end

    def visit(node : Crystal::FunDef)
      process_node node, node.name, SymbolKind::Function
      true
    end
    
    def visit(node : Crystal::Alias)
      process_node node, node.name, SymbolKind::Constant
      true
    end

    def visit(node : Crystal::Assign)
      if node.target.is_a?(Crystal::Path)
        process_node node, node.target.as(Crystal::Path).names.last, SymbolKind::Constant
      end
      true
    end

    def visit(node : Crystal::Expressions)
      true
    end

    def visit(node : Crystal::ASTNode)
      true
    end

    def end_visit(node : Crystal::ClassDef | Crystal::ModuleDef | Crystal::CStructOrUnionDef | Crystal::LibDef | Crystal::EnumDef)
      return unless node.location
      @container.pop?
    end

    def process_node(node, name : String, kind : SymbolKind)
      location = node.location
      return true unless location

      line_number = location.line_number
      column_number = location.column_number

      position = Position.new(line_number - 1, column_number - 1)
      range = Range.new(position, position)
      location = Location.new(@document_uri, range)

      @symbols << SymbolInformation.new(name, kind, location, @container.join("::"))

      true
    end
  end

  class SymbolProcessor
    def initialize(@text_document : TextDocument)
    end

    def run
      visitor = SymbolVisitor.new(@text_document.uri)
      parser = Crystal::Parser.new(@text_document.source)
      parser.filename = @text_document.filename
      node = parser.parse
      node.accept(visitor)

      ResponseMessage.new(@text_document.id, visitor.symbols)
    end
  end
end
