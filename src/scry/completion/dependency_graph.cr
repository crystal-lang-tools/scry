module Scry::Completion::DependencyGraph
  struct Node
    property value
    property connections

    def initialize(@value : String)
      @connections = Set(Node).new
    end

    def hash(hasher)
      @value.hash(hasher)
    end

    def descendants
      # Returns all the connections (first-degree and more) of this node.
      visit = connections.to_a
      visited = Set(Node).new
      while visit.size != 0
        check = visit.pop
        visited << check
        check.connections.reject { |e| visited.includes?(e) }.each { |e| visit << e }
      end
      visited
    end
  end

  class Graph
    def initialize(@nodes = {} of String => Node)
    end

    def [](value : String)
      @nodes[value]
    end

    def add_edge(value_1 : String, value_2 : String)
      add value_1
      add value_2
      @nodes[value_1].connections << @nodes[value_2]
    end

    def add(value : String)
      @nodes[value] = Node.new(value) unless @nodes[value]?
    end

    def [](value : Regex)
      @nodes[@nodes.keys.find(&.match(value))]?
    end

    def each(&block)
      @nodes.each do |k, v|
        yield k, v
      end
    end

    def each
      @nodes.each
    end
  end

  class Builder
    def initialize(@lookup_paths : Array(String))
    end

    def build
      Log.logger.debug("Starting to build dependancy graph for these paths: #{@lookup_paths.join("\n")}")
      graph = Graph.new
      @lookup_paths
        .map { |e| File.join(File.expand_path(e), "**", "*.cr") }
        .uniq
        .flat_map { |d| Dir.glob(d) }
        .each { |file| process_requires(file, graph) }

      prelude_node = graph[/src\/prelude.cr$/]
      Log.logger.debug("Finished building the dependancy graph got these nodes:#{graph.each.to_a.map(&.first)}")
      return graph if prelude_node.nil?

      graph.each.reject { |e| e == prelude_node.not_nil!.value }.each do |key, _|
        graph[key].connections << prelude_node.not_nil!
      end
      graph
    end

    def process_requires(file, graph)
      requires = parse_requires(file)
      current_file_path = File.expand_path(file)
      if (requires.empty?)
        graph.add(current_file_path)
        return
      end
      requires_so_far = [] of String
      requires.each do |required_file_path|
        if required_file_path.nil?
          next
        elsif required_file_path.ends_with?("*.cr")
          Dir.glob(required_file_path).sort.each do |p|
            graph.add_edge(current_file_path, p)
            requires_so_far.each { |pp| graph.add_edge(p, pp) }
            requires_so_far << p
          end
        else
          graph.add_edge(current_file_path, required_file_path)
          requires_so_far.each do |path|
            graph.add_edge(required_file_path, path)
          end
          requires_so_far << required_file_path
        end
      end
    end

    def parse_requires(file_path)
      file_dir = File.dirname(file_path)
      File.each_line(file_path).reduce([] of String) do |acc, line|
        require_statement = /^\s*require\s*\"(?<file>.*)\"\s*$/.match(line)
        unless require_statement.nil?
          path = resolve_path(require_statement.as(Regex::MatchData)["file"].not_nil!, file_dir)
          if path
            acc << path
          end
        end
        acc
      end
    end

    def resolve_path(required_file, file_dir)
      if required_file.starts_with?(".")
        "#{File.expand_path(required_file, file_dir)}.cr"
      else
        @lookup_paths.each do |e|
          path = "#{File.expand_path(required_file, e)}.cr"
          return path if File.exists?(path)
        end
      end
    end
  end
end
