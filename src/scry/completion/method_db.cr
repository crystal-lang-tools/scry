require "compiler/crystal/syntax"

module Scry::Completion
  class MethodDB
    property db

    def initialize
      @db = {} of String => Array(MethodDBEntry)
    end

    def matches(types : Array(String), text : String) : Array(MethodDBEntry)
      types.each.flat_map do |e|
        res = @db[e]?
        if res
          res
        else
          Log.logger.debug("Couldn't find type #{e}")
          [] of MethodDBEntry
        end
      end.select(&.name.starts_with? text).to_a
    end

    def type_match(text : String) : Array(String)
      @db.keys.select!(&.starts_with?(text)).reject!(&.ends_with?(".class"))
    end

    def self.generate(paths)
      new.tap do |method_db|
        paths.each do |path|
          next unless File.exists? path
          node = self.parse(path)
          visitor = Visitor.new(path)
          node.accept(visitor)
          method_db.db.merge!(visitor.classes_or_modules) { |_, _old, _new| _old + _new }
        end
      end
    end

    def self.parse(path)
      begin
        Crystal::Parser.parse(File.read path)
      rescue exception
        Crystal::Nop.new
      end
    end
  end

  struct MethodDBEntry
    property name : String
    property signature : String
    property file_path : String
    property location : String

    def initialize(@name, @signature, @file_path, @location)
    end
  end

  class Visitor < Crystal::Visitor
    property classes_or_modules
    property path_name = ""

    def initialize(@file : String)
      @classes_or_modules = {} of String => Array(MethodDBEntry)
      @path_queue = [] of Crystal::Path
    end

    def generate_name(paths : Array(Crystal::Path))
      paths.flat_map(&.names).compact.join("::")
    end

    def visit(node : Crystal::Def)
      return false if @path_queue.empty? || node.visibility != Crystal::Visibility::Public
      if node.name == "initialize"
        name = "new"
        method_receiver = "#{@path_name}.class"
        return_type = @path_name
      else
        name = node.name
        method_receiver = node.receiver ? "#{@path_name}.class" : @path_name
      end
      signature = "(#{node.args.map(&.to_s).join(", ")}) : #{return_type || node.return_type.to_s}"
      @classes_or_modules[method_receiver] << MethodDBEntry.new(name, signature, @file, node.location.to_s)
      false
    end

    def visit(node : Crystal::ClassDef)
      @path_queue << node.name
      @path_name = generate_name(@path_queue)
      @classes_or_modules["#{@path_name}.class"] = [] of MethodDBEntry
      @classes_or_modules[@path_name] = [] of MethodDBEntry
      true
    end

    def end_visit(node : Crystal::ClassDef|Crystal::ModuleDef)
      @path_queue.pop
      @path_name = generate_name(@path_queue)
    end

    def visit(node : Crystal::ModuleDef)
      @path_queue << node.name
      @classes_or_modules[generate_name(@path_queue)] = [] of MethodDBEntry
      true
    end

    def visit(node : Crystal::Expressions)
      true
    end

    def visit(node)
      false
    end
  end
end
