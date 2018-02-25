require "../spec_helper"

module Scry
  describe SymbolProcessor do
    it "returns a ResponseMessage" do
      text_document = TextDocument.new("inmemory://model/3", [""])
      processor = SymbolProcessor.new(text_document)
      processor.run.is_a?(ResponseMessage).should be_true
    end

    it "contains SymbolInformation" do
      text_document = TextDocument.new("uri", [""])
      processor = SymbolProcessor.new(text_document)
      response = processor.run
      response.result.is_a?(Array(SymbolInformation)).should be_true
    end

    it "returns Class symbols" do
      text_document = TextDocument.new("uri", ["class Test; end"])
      processor = SymbolProcessor.new(text_document)
      response = processor.run
      result = response.result.try(&.first)
      result.as(SymbolInformation).kind.is_a?(SymbolKind::Class).should be_true
    end

    it "returns Struct symbols as a Class" do
      text_document = TextDocument.new("uri", ["struct Test; end"])
      processor = SymbolProcessor.new(text_document)
      response = processor.run
      result = response.result.try(&.first)
      result.as(SymbolInformation).kind.is_a?(SymbolKind::Class).should be_true
    end

    it "returns Module symbols" do
      text_document = TextDocument.new("uri", ["module Test; end"])
      processor = SymbolProcessor.new(text_document)
      response = processor.run
      result = response.result.try(&.first)
      result.as(SymbolInformation).kind.is_a?(SymbolKind::Module).should be_true
    end

    it "returns Method symbols" do
      text_document = TextDocument.new("uri", ["def test; end"])
      processor = SymbolProcessor.new(text_document)
      response = processor.run
      result = response.result.try(&.first)
      result.as(SymbolInformation).kind.is_a?(SymbolKind::Method).should be_true
    end

    it "returns instance vars as Variable symbols" do
      text_document = TextDocument.new("uri", ["@bar = nil"])
      processor = SymbolProcessor.new(text_document)
      response = processor.run
      result = response.result.try(&.first)
      result.as(SymbolInformation).kind.is_a?(SymbolKind::Variable).should be_true
    end

    describe "Property" do
      it "returns getters as Property symbols" do
        text_document = TextDocument.new("uri", ["class Foo; getter bar : Nil; end"])
        processor = SymbolProcessor.new(text_document)
        response = processor.run
        result = response.result.try { |r| r[1] }
        result.as(SymbolInformation).kind.is_a?(SymbolKind::Property).should be_true
      end

      it "returns setters as Property symbols" do
        text_document = TextDocument.new("uri", ["class Foo; setter bar : Nil; end"])
        processor = SymbolProcessor.new(text_document)
        response = processor.run
        result = response.result.try { |r| r[1] }
        result.as(SymbolInformation).kind.is_a?(SymbolKind::Property).should be_true
      end

      it "returns properties as Property symbols" do
        text_document = TextDocument.new("uri", ["class Foo; property bar : Nil; end"])
        processor = SymbolProcessor.new(text_document)
        response = processor.run
        result = response.result.try { |r| r[1] }
        result.as(SymbolInformation).kind.is_a?(SymbolKind::Property).should be_true
      end
    end

    describe "Constants" do
      it "returns Constant symbols" do
        text_document = TextDocument.new("uri", [%(HELLO = "world")])
        processor = SymbolProcessor.new(text_document)
        response = processor.run
        result = response.result.try(&.first)
        result.as(SymbolInformation).kind.is_a?(SymbolKind::Constant).should be_true
      end

      it "returns alias as Constant symbols" do
        text_document = TextDocument.new("uri", [%(alias Hello = World)])
        processor = SymbolProcessor.new(text_document)
        response = processor.run
        result = response.result.try(&.first)
        result.as(SymbolInformation).kind.is_a?(SymbolKind::Constant).should be_true
      end
    end
  end
end
