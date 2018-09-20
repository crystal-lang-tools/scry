require "./completion/dependency_graph"
require "./completion/method_db"

module Scry
  struct Workspace
    property root_uri : String
    property process_id : Int32 | Int64 | Nil
    property max_number_of_problems : Int32
    property open_files
    property dependency_graph : Completion::DependencyGraph::Graph

    @lookup_path : Array(String)

    def initialize(root_uri, process_id, max_number_of_problems)
      @root_uri = root_uri
      @process_id = process_id
      @max_number_of_problems = max_number_of_problems
      @open_files = {} of String => {TextDocument, Completion::MethodDB}
      @dependency_graph = Completion::DependencyGraph::Graph.new
      @lookup_path = (ENV["CRYSTAL_PATH"].split(":") << @root_uri)
    end

    def open_workspace
      @dependency_graph = Completion::DependencyGraph::Builder.new(@lookup_path).build
    end

    def reopen_workspace(file)
      @dependency_graph = Completion::DependencyGraph::Builder.new(@lookup_path).rebuild(@dependency_graph, file.filename)
      file_dependencies = @dependency_graph[file.filename].descendants.map &.value
      method_db = Completion::MethodDB.generate(file_dependencies)
      @open_files[file.filename] = {file, method_db}
    end

    def put_file(text_document : TextDocument)
      if @dependency_graph[text_document.filename]?
        file_dependencies = @dependency_graph[text_document.filename].descendants.map &.value
      else
        file_dependencies = @dependency_graph.prelude_node.descendants.map &.value
      end
      file_dependencies << text_document.filename
      method_db = Completion::MethodDB.generate(file_dependencies.uniq!)
      @open_files[text_document.filename] = {text_document, method_db}
    end

    def update_file(text_document : TextDocument)
      original_document, node = @open_files[text_document.filename]
      if original_document.text != text_document.text
        put_file(text_document)
      else
        @open_files[text_document.filename]
      end
    end

    def drop_file(text_document : TextDocument)
      @open_files.delete(text_document.filename)
      @dependency_graph.delete(text_document.filename)
    end

    def get_file(file_name)
      @open_files[file_name]
    end
  end
end
