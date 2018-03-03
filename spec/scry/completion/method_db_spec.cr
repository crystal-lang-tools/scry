require "../../spec_helper"

module Scry::Completion
  describe MethodDB do
    it ".generate" do
      context "sample and sample_2" do
        path = File.expand_path("spec/fixtures/completion/method_db/sample.cr")
        path_2 = File.expand_path("spec/fixtures/completion/method_db/sample_2.cr")

        method_db = MethodDB.generate([
          path,
          path_2,
        ])
        method_db.db["A"].map(&.name).should eq(["method_a", "method_b"]), "handles instance methods"
        method_db.db["A.class"].map(&.name).should eq(["new", "class_method"]), "handles class methods and initialize properly"
        method_db.db["A.class"].map(&.signature).should eq(["() : A", "(c : Int32) : Int32"]), "handles basic method_signature"
        method_db.db["C"].map(&.name).should eq(["method_a", "method_c"]), "handles class reopens"
      end
    end
  end
end
