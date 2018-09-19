require "../spec_helper"
require "tempfile"

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

    describe ".put_file" do
      it "adds a file and generates it's method db" do
        source = Tempfile.new("test") # This will need to change w/ v0.27.0
        File.write(source.path, "class A; def hello; end; end;")
        text_document = TextDocument.new(source.path)

        workspace = Workspace.new("root", 0, 10)
        workspace.open_files[source.path]?.should be_nil

        _, method_db = workspace.put_file(text_document)

        workspace.open_files[source.path].should_not be_nil
        method_db.db["A"].size.should eq(1)
        method_db.db["A"][0].name.should eq("hello")
      end
    end

    describe ".update_file" do
      it "updates an existing file and it's method db" do
        source = Tempfile.new("test") # This will need to change w/ v0.27.0
        File.write(source.path, "class A; def hello; end; end;")
        text_document = TextDocument.new(source.path)
        workspace = Workspace.new("root", 0, 10)

        workspace.put_file(text_document)
        File.write(source.path, "class A; def hello2; end; end;")
        text_document.text = [File.read(source.path)]

        _, method_db = workspace.update_file(text_document)

        workspace.open_files[source.path].should_not be_nil
        method_db.db["A"].size.should eq(1)
        method_db.db["A"][0].name.should eq("hello2")
      end
    end

    describe ".drop_file" do
      it "removes a file from the workspace" do
        source = Tempfile.new("test") # This will need to change w/ v0.27.0
        File.write(source.path, "class A; def hello; end; end;")
        text_document = TextDocument.new(source.path)
        workspace = Workspace.new("root", 0, 10)

        _, method_db = workspace.put_file(text_document)
        workspace.open_files[source.path].should_not be_nil

        workspace.drop_file(text_document)
        workspace.open_files[source.path]?.should be_nil
      end
    end

    describe ".get_file" do
      it "retrieves a file and its method db from the workspace" do
        source = Tempfile.new("test") # This will need to change w/ v0.27.0
        File.write(source.path, "class A; def hello; end; end;")
        text_document = TextDocument.new(source.path)
        workspace = Workspace.new("root", 0, 10)

        _, method_db = workspace.put_file(text_document)
        workspace.open_files[source.path].should_not be_nil

        document, method_db = workspace.get_file(text_document)
        document.filename.should eq(source.path)
        method_db.db["A"].size.should eq(1)
        method_db.db["A"][0].name.should eq("hello")
      end
    end
  end
end
