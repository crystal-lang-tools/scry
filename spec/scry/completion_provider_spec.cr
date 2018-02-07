require "../spec_helper"

module Scry
  describe CompletionProvider do
    it "handles require module completions for crystal modules" do
      tree_path = File.expand_path("spec/fixtures/completion/tree.cr")
      text_content = "require \"arr"
      text_document = TextDocument.new(tree_path, [text_content])
      position = Position.new(line=0, character=text_content.size)
      completion_provider = CompletionProvider.new(text_document, context: nil, position: position)

      results = completion_provider.run

      results.size.should eq(1)

      result = results.first
      result.label.should eq("array")
      result.insert_text.should eq("array")
      result.kind.should eq(CompletionItemKind::Module)
      result.documentation.should be_nil
    end

    it "handles require module completions for relative path" do
      tree_path = File.expand_path("spec/fixtures/completion/tree.cr")
      text_content = "require \"./"
      text_document = TextDocument.new(tree_path, [text_content])
      position = Position.new(line=0, character=text_content.size)
      completion_provider = CompletionProvider.new(text_document, context: nil, position: position)

      results = completion_provider.run

      labels = results.map &.label

      results.size.should eq(1)
      labels.should eq(["sample"])
    end
  end
end
