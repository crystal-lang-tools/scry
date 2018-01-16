require "compiler/crystal/syntax"

require "./db"
require "./db_visitor"

module Scry::Completion
  class Completion
    getter db
    getter processed_files

    @db : Db
    @visitor : DbVisitor

    @processed_files = 0

    # def self.add_paths(db : Db, paths : Array(String))
    #   gen = Initializer.new db, paths
    #   gen.processed_files
    # end

    def initialize(@paths : Array(String))
      @db = Db.new
      @visitor = DbVisitor.new @db
      compute_paths
    end

    def initialize(@db : Db, @paths : Array(String))
      @visitor = DbVisitor.new @db
      compute_paths
    end

    def compute_paths
      @paths.each do |path|
        Dir.glob "#{path}/**/*.cr" do |filename|
          parse filename
        end
      end
    end

    def parse(filename : String)
      @processed_files += 1
      node = Crystal::Parser.parse File.read(filename)
      @visitor.current_file = filename
      node.accept @visitor
    end
  end
end