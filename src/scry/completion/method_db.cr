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

    def self.generate(paths)
      new.tap do |method_db|
        paths.each do |path|
          next unless File.exists? path
          node = Crystal::Parser.parse(File.read path)
          visitor = Visitor.new(path)
          node.accept(visitor)
          method_db.db.merge!(visitor.classes) { |_, _old, _new| _old + _new }
        end
      end
    end
  end

  struct MethodDBEntry
    property name : String
    property signature : String

    def initialize(@name, @signature)
    end
  end

  class Visitor < Crystal::Visitor
    property classes

    def initialize(@file : String)
      @classes = {} of String => Array(MethodDBEntry)
      @class_queue = [] of String
    end

    def visit(node : Crystal::Def)
      return false if @class_queue.empty? || node.visibility != Crystal::Visibility::Public
      if node.name == "initialize"
        name = "new"
        method_receiver = "#{@class_queue.last}.class"
        return_type = @class_queue.last
      else
        name = node.name
        method_receiver = node.receiver ? "#{@class_queue.last}.class" : @class_queue.last
      end
      signature = "(#{node.args.map(&.to_s).join(", ")}) : #{return_type || node.return_type.to_s}"
      @classes[method_receiver] << MethodDBEntry.new(name, signature)
      false
    end

    def visit(node : Crystal::ClassDef)
      @classes["#{node.name.to_s}.class"] = [] of MethodDBEntry
      @classes[node.name.to_s] = [] of MethodDBEntry
      @class_queue << node.name.to_s
      true
    end

    def end_visit(node : Crystal::ClassDef)
      @class_queue.pop
    end

    def visit(node : Crystal::ModuleDef)
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
