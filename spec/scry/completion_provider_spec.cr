require "../spec_helper"

module Scry
  private macro it_completes(code, with_labels, file = __FILE__, line = __LINE__)

    it "completes #{{{code}}}" do
      procedure = Message.new %({"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"#{__FILE_PATH__}","languageId":"crystal","version":1,"text":"#{{{code}}}"}}})
      result = __CONTEXT__.dispatch(procedure.parse)

      procedure = Message.new(%({"jsonrpc": "2.0", "id": 1, "method": "textDocument/completion", "params": {"textDocument":{"uri":"#{__FILE_PATH__}"},"position":{"line":0,"character":#{{{code}}.size}}}}))
      response = __CONTEXT__.dispatch(procedure.parse).as(Scry::ResponseMessage)
      results = response.result.as(Array(CompletionItem))
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
