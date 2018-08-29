require "../spec_helper"

module Scry
  describe SymbolProcessor do
    it "contains SymbolInformation" do
      text_document = TextDocument.new("uri", [""])
      processor = SymbolProcessor.new(text_document)
      symbols = processor.run
      symbols.should be_a(Array(Protocol::SymbolInformation))
    end

    it "returns Class symbols" do
      text_document = TextDocument.new("uri", ["class Test; end"])
      processor = SymbolProcessor.new(text_document)
      symbols = processor.run
      result = symbols.first
      result.kind.should be_a(Protocol::SymbolKind::Class)
    end

    it "returns Struct symbols as a Class" do
      text_document = TextDocument.new("uri", ["struct Test; end"])
      processor = SymbolProcessor.new(text_document)
      symbols = processor.run
      result = symbols.first
      result.kind.should be_a(Protocol::SymbolKind::Class)
    end

    it "returns Module symbols" do
      text_document = TextDocument.new("uri", ["module Test; end"])
      processor = SymbolProcessor.new(text_document)
      symbols = processor.run
      result = symbols.first
      result.kind.should be_a(Protocol::SymbolKind::Module)
    end

    it "returns Method symbols" do
      text_document = TextDocument.new("uri", ["def test; end"])
      processor = SymbolProcessor.new(text_document)
      symbols = processor.run
      result = symbols.first
      result.kind.should be_a(Protocol::SymbolKind::Method)
    end

    it "returns instance vars as Variable symbols" do
      text_document = TextDocument.new("uri", ["@bar = nil"])
      processor = SymbolProcessor.new(text_document)
      symbols = processor.run
      result = symbols.first
      result.kind.should be_a(Protocol::SymbolKind::Variable)
    end

    describe "Property" do
      it "returns getters as Property symbols" do
        text_document = TextDocument.new("uri", ["class Foo; getter bar : Nil; end"])
        processor = SymbolProcessor.new(text_document)
        symbols = processor.run
        result = symbols[1]
        result.kind.should be_a(Protocol::SymbolKind::Property)
      end

      it "returns setters as Property symbols" do
        text_document = TextDocument.new("uri", ["class Foo; setter bar : Nil; end"])
        processor = SymbolProcessor.new(text_document)
        symbols = processor.run
        result = symbols[1]
        result.kind.should be_a(Protocol::SymbolKind::Property)
      end

      it "returns properties as Property symbols" do
        text_document = TextDocument.new("uri", ["class Foo; property bar : Nil; end"])
        processor = SymbolProcessor.new(text_document)
        symbols = processor.run
        result = symbols[1]
        result.kind.should be_a(Protocol::SymbolKind::Property)
      end
    end

    describe "Constants" do
      it "returns Constant symbols" do
        text_document = TextDocument.new("uri", [%(HELLO = "world")])
        processor = SymbolProcessor.new(text_document)
        symbols = processor.run
        result = symbols.first
        result.kind.should be_a(Protocol::SymbolKind::Constant)
      end

      it "returns alias as Constant symbols" do
        text_document = TextDocument.new("uri", [%(alias Hello = World)])
        processor = SymbolProcessor.new(text_document)
        symbols = processor.run
        result = symbols.first
        result.kind.should be_a(Protocol::SymbolKind::Constant)
      end
    end

    describe "WorkspaceSymbols" do
      it "return empty Symbols list if no query" do
        processor = WorkspaceSymbolProcessor.new(ROOT_PATH, "")
        symbols = processor.run
        symbols.empty?.should be_true
      end

      it "return Symbols list with query match for saluto (example file)" do
        processor = WorkspaceSymbolProcessor.new(ROOT_PATH, "saluto")
        symbols = processor.run
        result = symbols.first
        result.kind.should be_a(Protocol::SymbolKind::Method)
      end

      it "return stdlib symbol with query match for initialize" do
        processor = WorkspaceSymbolProcessor.new(ROOT_PATH, "initialize")
        symbols = processor.run
        result = symbols.first
        result.kind.should be_a(Protocol::SymbolKind::Method)
      end
    end
  end
end
