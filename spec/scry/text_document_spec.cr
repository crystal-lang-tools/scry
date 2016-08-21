require "../spec_helper"
require "../../src/scry/text_document"

module Scry

  describe TextDocument do

    it "handles in memory documents" do
      text_document = TextDocument.new("inmemory://model/3", [%(puts "foo")])
      text_document.in_memory?.should be_true
    end
  end

end
