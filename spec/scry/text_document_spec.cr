require "../spec_helper"

module Scry
  describe TextDocument do
    it "handles in memory documents" do
      text_document = TextDocument.new("inmemory://model/3", [%(puts "foo")])
      text_document.in_memory?.should be_true
    end

    it "handles updates to content" do
      path = "spec/fixtures/completion/sample.cr"
      uri = "file://#{File.expand_path(path)}"
      text_document = TextDocument.new(uri, [File.read(path)])
      text_document.update_change(TextDocumentContentChangeEvent.from_json(%({"range": {"start": {"line": 2, "character": 5}, "end": {"line": 2, "character": 15}}, "text": "def method\\n a + b\\n"} )))
      text_document.text.should eq([
        "class A\n    def method\n a + b\n    end\nend"
      ])
    end
  end
end
