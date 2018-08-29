require "../spec_helper"

module Scry
  describe CompletionResolver do
    it "handles require module completions" do
      tree_path = File.expand_path("spec/fixtures/completion/tree.cr")
      context = Protocol::RequireModuleContextData.new(tree_path)
      completion_item = Protocol::CompletionItem.new(label = "mock", kind = Protocol::CompletionItemKind::Text, detail = "mock detail", data = context, documentation = nil)
      completion_resolver = CompletionResolver.new(1, completion_item)

      results = completion_resolver.run.as(Protocol::CompletionItem)
      doc = results.documentation.as(Protocol::MarkupContent)
      doc.value.should eq("```crystal\n# taken from https://raw.githubusercontent.com/crystal-lang/crystal/master/samples/tree.cr\nclass Node\n  @left : self?\n  @right : self?\n\n```")
    end

    it "handles method completions" do
      tree_path = File.expand_path("spec/fixtures/completion/tree.cr")
      context = Protocol::MethodCallContextData.new(tree_path, ":10:3")
      completion_item = Protocol::CompletionItem.new(label = "mock", kind = Protocol::CompletionItemKind::Text, detail = "mock detail", data = context, documentation = nil)
      completion_resolver = CompletionResolver.new(1, completion_item)

      results = completion_resolver.run.as(Protocol::CompletionItem)
      doc = results.documentation.as(Protocol::MarkupContent)
      doc.value.should eq(" Adds a node to the tree")
    end
  end
end
