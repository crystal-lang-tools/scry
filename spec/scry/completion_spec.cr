require "../spec_helper"

module Scry
  module Completion
    describe Completion do
      it "builds from directory" do
        completion = Completion.new(["#{Dir.current}/spec/fixtures/completion"])
        print(completion.db.with_context("Node.new.a"))
      end
    end
  end
end
