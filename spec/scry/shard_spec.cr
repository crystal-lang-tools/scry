require "../spec_helper"

module Scry
  describe Shard do
    it "works with empty yamls" do
      Shard.new "spec/fixtures/shard/nothing.yml"
    end

    it "loads dependencies" do
      shard = Shard.new "spec/fixtures/shard/deps.yml"
      shard.dependencies.should eq ["openssl"]
    end

    it "loads dev dependecies" do
      shard = Shard.new "spec/fixtures/shard/dev_deps.yml"
      shard.dependencies.should eq ["minitest"]
    end
  end
end
