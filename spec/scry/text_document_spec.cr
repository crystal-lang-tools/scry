require "../spec_helper"

module Scry
  describe TextDocument do
    it "handles in memory documents" do
      text_document = TextDocument.new("inmemory://model/3", [%(puts "foo")])
      text_document.in_memory?.should be_true
    end
  end
end
