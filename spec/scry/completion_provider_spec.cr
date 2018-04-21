require "../spec_helper"

module Scry
  private macro it_completes(code, with_labels, file = __FILE__, line = __LINE__)

    it "completes #{{{code}}}" do
      __CONTEXT__.test_send_did_open(__FILE_PATH__, {{code}})
      response = __CONTEXT__.test_send_completion(__FILE_PATH__, %({"line":0,"character":#{{{code}}.size}}))

      results = response.as(Scry::ResponseMessage).result.as(Array(CompletionItem))
      labels = results.map(&.label)
      labels.should eq({{with_labels}})

      results.each do |e|
        e.kind.should eq(__KIND__)
      end
    end
  end

  describe CompletionProvider do
    context "module completion" do
      __KIND__ = CompletionItemKind::Module
      __CONTEXT__ = Context.new
      root_path = File.expand_path("spec/fixtures/completion/")
      __CONTEXT__.test_send_init(root_path)

      __FILE_PATH__ = File.join(root_path, "tree.cr")

      it_completes("require \\\"arr", ["array"])
      it_completes("require \\\"./sa", ["sample"])
    end
  end
end
