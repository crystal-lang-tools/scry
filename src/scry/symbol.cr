require "compiler/crystal/syntax"

module Scry
  class SymbolVisitor < Crystal::Visitor
    getter symbols

    def initialize(@document_uri : String)
      @container = [] of String
      @symbols = [] of LSP::Protocol::SymbolInformation
    end

    def visit(node : Crystal::ClassDef)
      process_node node, node.name.names.last, LSP::Protocol::SymbolKind::Class
      @container << node.name.names.last
      true
    end

    def visit(node : Crystal::EnumDef)
      process_node node, node.name.names.last, LSP::Protocol::SymbolKind::Enum
      @container << node.name.names.last
      true
    end

    def visit(node : Crystal::ModuleDef)
      process_node node, node.name.names.last, LSP::Protocol::SymbolKind::Module
      @container << node.name.names.last
      true
    end

    def visit(node : Crystal::Def)
      process_node node, node.name, LSP::Protocol::SymbolKind::Method
      false
    end

    def visit(node : Crystal::LibDef)
      process_node node, node.name, LSP::Protocol::SymbolKind::Package
      @container << node.name
      true
    end

    def visit(node : Crystal::StructOrUnionDef)
      process_node node, node.name, LSP::Protocol::SymbolKind::Class
      @container << node.name
      true
    end

    def visit(node : Crystal::FunDef)
      process_node node, node.name, LSP::Protocol::SymbolKind::Function
      true
    end

    def visit(node : Crystal::Alias)
      process_node node, node.name.names.last, LSP::Protocol::SymbolKind::Constant
      true
    end

    def visit(node : Crystal::Assign)
      if node.target.is_a?(Crystal::Path)
        process_node node, node.target.as(Crystal::Path).names.last, LSP::Protocol::SymbolKind::Constant
      end
      true
    end

    def visit(node : Crystal::Expressions)
      true
    end

    def visit(node : Crystal::ASTNode)
      true
    end

    def visit(node : Crystal::Var)
      process_node node, node.name, LSP::Protocol::SymbolKind::Property
      true
    end

    def visit(node : Crystal::InstanceVar)
      process_node node, node.name, LSP::Protocol::SymbolKind::Variable
      true
    end

    def end_visit(node : Crystal::ClassDef | Crystal::ModuleDef | Crystal::CStructOrUnionDef | Crystal::LibDef | Crystal::EnumDef)
      return unless node.location
      @container.pop?
    end

    def process_node(node, name : String, kind : LSP::Protocol::SymbolKind)
      location = node.location
      return unless location

      line_number = location.line_number
      column_number = location.column_number
      position = LSP::Protocol::Position.new(line_number - 1, column_number - 1)

      if end_location = node.end_location
        end_line_number = end_location.line_number
        end_column_number = end_location.column_number
      else
        end_line_number = line_number
        end_column_number = column_number
      end
      end_position = LSP::Protocol::Position.new(end_line_number - 1, end_column_number - 1)

      range = LSP::Protocol::Range.new(position, end_position)
      location = LSP::Protocol::Location.new(@document_uri, range)
      @symbols << LSP::Protocol::SymbolInformation.new(name, kind, location, @container.join("::"))
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
      visitor.symbols
    rescue
      [] of LSP::Protocol::SymbolInformation
    end
  end

  class WorkspaceSymbolProcessor
    @@crystal_path_symbols : Array(LSP::Protocol::SymbolInformation)?

    def initialize(@root_path : String, @query : String)
      @workspace_files = Dir.glob(File.join(root_path, "**", "*.cr"))
    end

    def run
      return [] of LSP::Protocol::SymbolInformation if @query.empty?
      self.class.search_symbols(@workspace_files, @query).concat(
        self.class.crystal_path_symbols.select(&.name.includes?(@query))
      )
    end

    def self.crystal_path_symbols
      @@crystal_path_symbols ||= begin
        crystal_path_files = Dir.glob(File.join(Scry.default_crystal_path, "**", "*.cr"))
        search_symbols(crystal_path_files, "")
      end
    end

    def self.search_symbols(files, query)
      symbols = [] of LSP::Protocol::SymbolInformation
      files.each do |file|
        processor = SymbolProcessor.new(TextDocument.new("file://#{file}"))
        symbols.concat processor.run.select(&.name.includes?(query))
      rescue
        next
      end
      symbols
    end
  end
end
