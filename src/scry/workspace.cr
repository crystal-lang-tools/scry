require "./completion/dependency_graph"
require "./completion/method_db"

module Scry
  struct Workspace
    property root_uri : String
    property process_id : Int32 | Int64 | Nil
    property max_number_of_problems : Int32
    property open_files
    property dependency_graph : Completion::DependencyGraph::Graph

    def initialize(root_uri, process_id, max_number_of_problems)
      @root_uri = root_uri
      @process_id = process_id
      @max_number_of_problems = max_number_of_problems
      @open_files = {} of String => {TextDocument, Completion::MethodDB}
      @dependency_graph = Completion::DependencyGraph::Graph.new
    end

    def open_workspace
      @dependency_graph = Completion::DependencyGraph::Builder.new(ENV["CRYSTAL_PATH"].split(":") + [@root_uri]).build
    end

    def put_file(params : DidOpenTextDocumentParams)
      file = TextDocument.new(params)
      if @dependency_graph[file.filename]?
        file_dependencies = @dependency_graph[file.filename].descendants.map &.value
      else
        file_dependencies = @dependency_graph.prelude_node.descendants.map &.value
      end
      file_dependencies << file.filename
      method_db = Completion::MethodDB.generate(file_dependencies.uniq!)
      @open_files[file.filename] = {file, method_db}
    end

    def update_file(params : DidChangeTextDocumentParams)
      file = TextDocument.new params
      _, node = @open_files[file.filename]
      @open_files[file.filename] = {file, node}
    end

    def drop_file(params : TextDocumentParams)
      filename = TextDocument.uri_to_filename(params.text_document.uri)
      @open_files.delete(filename)
    end

    def get_file(text_document : TextDocumentIdentifier)
      filename = TextDocument.uri_to_filename(text_document.uri)
      Log.logger.debug("@open_files: #{@open_files}")
      @open_files[filename]
    end
  end
end
