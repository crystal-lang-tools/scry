require "../spec_helper"

module Scry
  describe CompletionResolver do
    it "handles require module completions" do
      tree_path = File.expand_path("spec/fixtures/completion/tree.cr")
      context = RequireModuleContextData.new(tree_path)
      completion_item = CompletionItem.new(label="mock", kind=CompletionItemKind::Text, detail="mock detail", data=context, documentation = nil)
      completion_resolver = CompletionResolver.new(1, completion_item)

      results = completion_resolver.run.as(CompletionItem)
      doc = results.documentation.as(MarkupContent)
      doc.value.should eq("```crystal \n# taken from https://raw.githubusercontent.com/crystal-lang/crystal/master/samples/tree.cr\nclass Node\n    @left : self?\n    @right : self?\n \n ```")
    end
  end
end
