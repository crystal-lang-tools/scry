require "../spec_helper"

module Scry
  describe Workspace do
    it ".new" do
      workspace = Workspace.new("root_uri", 0, 10)
      workspace.dependency_graph.class.should eq Scry::Completion::DependencyGraph::Graph
      workspace.dependency_graph.each.to_a.size.should eq 1
    end

    it ".open_workspace" do
      root_uri = File.expand_path("spec/fixtures/completion")
      workspace = Workspace.new(root_uri, 0, 10)

      workspace.open_workspace

      workspace.dependency_graph.each.to_a.size.should_not eq 1
    end

    it ".update_file" do
    end

    it ".put_file" do
    end
  end
end
