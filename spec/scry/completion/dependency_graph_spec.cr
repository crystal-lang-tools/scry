require "../../spec_helper"
# require "./helper"

ROOT = File.expand_path("spec/fixtures/completion/dependency_graph")

CRYSTAL_PATH = Crystal::CrystalPath.default_path.split(":").last
PRELUDE_PATH = File.expand_path("prelude.cr", CRYSTAL_PATH)

def expand(paths : Array(String))
  paths.map { |p| expand(p) }
end

def expand(path : String)
  File.expand_path(path, ROOT)
end

module Scry::Completion::DependencyGraph
  describe Node do
    it ".new" do
      node = Node.new("node_value")

      node.value.should eq("node_value")
      node.connections.should eq(Set(Node).new)
    end

    it "#hash" do
      node = Node.new("node_value")

      node.hash.should eq("node_value".hash), "hash should be the node's value hash"
    end

    it "#decendants" do
      node_1 = Node.new("node_value")
      node_2 = Node.new("node_value_2")
      node_3 = Node.new("node_value_3")

      node_1.connections << node_2
      node_2.connections << node_3

      node_1.descendants.should eq(Set(Node).new([node_2, node_3]))
    end
  end

  describe Graph do
    it ".new" do
      graph = Graph.new
    end

    it "#[String]" do
      node = Node.new("value")
      graph = Graph.new({node.value => node})
      graph["value"].should eq(node)
    end

    it "#add_edge" do
      graph = Graph.new

      graph.add_edge("value_1", "value_2")
      graph["value_2"].should eq(Node.new("value_2"))
      graph["value_1"].connections.should eq(Set.new([Node.new("value_2")]))
    end

    it "#each" do
      graph = Graph.new
      graph.add_edge("value_1", "value_2")
      keys = [] of String

      graph.each do |k, v|
        keys << k
      end

      keys.select(&.match(/value_\d/)).should eq(["value_1", "value_2"])
    end
  end
  describe Builder do
    it ".new" do
      builder = Builder.new([] of String)
    end

    it "#build" do
      context "single file no requires with crystal path" do
        path = expand "single_file_no_requires"
        sample_1 = expand "single_file_no_requires/sample_1.cr"
        builder = Builder.new([CRYSTAL_PATH, path])

        graph = builder.build
        graph[sample_1].connections.map(&.value).should eq([PRELUDE_PATH])
      end

      context "single file no requires with crystal path implicit" do
        path = expand "single_file_no_requires"
        sample_1 = expand "single_file_no_requires/sample_1.cr"
        builder = Builder.new([path])

        graph = builder.build
        graph[sample_1].connections.map(&.value).should eq([PRELUDE_PATH])
      end

      context "single file relative import" do
        sample_1 = expand "single_file_no_requires/sample_1.cr"
        relative_import_file = expand "single_file_no_requires/single_file_relative_import.cr"

        builder = Builder.new([expand("single_file_no_requires")])

        graph = builder.build
        graph[relative_import_file].connections.map(&.value).should eq([sample_1, PRELUDE_PATH])
      end

      context "wildcard imports" do
        sample_1 = expand "single_file_no_requires/sample_1.cr"
        sample_2 = expand "single_file_no_requires/sample_2.cr"
        relative_import_file = expand "single_file_no_requires/single_file_relative_import.cr"
        wildcard_import_file = expand "wildcard_import.cr"
        builder = Builder.new([ROOT])

        graph = builder.build

        graph[wildcard_import_file].connections.map(&.value).sort.should eq([sample_1, sample_2, relative_import_file, PRELUDE_PATH].sort)
        graph[sample_2].connections.map(&.value).sort.should eq([sample_1, PRELUDE_PATH])
        graph[relative_import_file].connections.map(&.value).sort.should eq([sample_1, sample_2, PRELUDE_PATH])
      end
    end
  end
end
