require "compiler/crystal/syntax"
require "./db"

module Scry::Completion
  class DbVisitor < Crystal::Visitor
    property current_file

    @current_file : String
    @class_pop = Hash(Crystal::ClassDef, Int32).new
    @module_pop = Hash(Crystal::ModuleDef, Int32).new

    def initialize(@db : Db)
      @current_file = ""
    end

    def visit(node : Crystal::ModuleDef)
      ns = node.name.to_s.split "::"
      @module_pop[node] = ns.size

      if ns.size > 1
        ns[0..-2].each do |namespace|
          @db.push_module namespace, @current_file
        end
      end

      @db.push_module ns.last, @current_file
      true
    end

    def visit(node : Crystal::ClassDef)
      s = node.name.to_s.split "::"
      @class_pop[node] = s.size - 1

      if s.size > 1
        s[0..-2].each do |namespace|
          @db.push_module namespace, @current_file
        end
      end

      @db.push_class node, @current_file
      true
    end

    def visit(node : Crystal::Def)
      @db.push_def node, current_file if node.visibility == Crystal::Visibility::Public
      false
    end

    def visit(node : Crystal::Expressions)
      true
    end

    def end_visit(node : Crystal::ModuleDef)
      times = @module_pop[node]
      times.times do |_|
        @db.pop_module
      end
      @module_pop.delete node
    end

    def end_visit(node : Crystal::ClassDef)
      @class_pop[node].times do |_|
        @db.pop_module
      end
      @db.pop_class
    end

    def visit(node)
      false
    end
  end
end