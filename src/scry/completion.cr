require "./log"
require "compiler/crystal/crystal_path"

module Scry
  # struct CompletionContext
  #   type
  # end

  abstract class AutoCompletionContext
    abstract def find : Array(CompletionItem)
  end
  class UnrecognizedContext < Exception
  end

  class InstanceMethodCallContext < AutoCompletionContext
    def initialize(@target : String, @method : String, @line : String, @text_document : TextDocument)
    end

    def find
      # to_completion_items(["Results", "And", "more", "results"])
      # TODO implement method call comlpetion


      [] of CompletionItem
    end

    def to_completion_items(results : Array(String))
      results.map do |res|
        CompletionItem.new(res, CompletionItemKind::Method, res)
      end
    end
  end

  class InstanceVariableContext < AutoCompletionContext
    def initialize(@var : String, @line : String, @text_document : TextDocument)
    end

    def find
      # to_completion_items(["Results", "And", "more", "results"])
      # TODO implement instance variable completion
      [] of CompletionItem
    end

    def to_completion_items(results : Array(String))
      results.map do |res|
        CompletionItem.new(res, CompletionItemKind::Variable, res)
      end
    end
  end

  class ImportModuleContext < AutoCompletionContext
    def initialize(@import : String, @text_document : TextDocument)
    end

    def find
      return find_module(@import)
      case @import
      when /^\./
        find_relative(@import)
      else
        find_module(@import)
      end
    end

    def find_relative(path)
      [] of CompletionItem
    end

    def find_module(path)
      paths = Crystal::CrystalPath.default_path.split(":")
                                  .select{|e| File.exists?(e)}
                                  .map{|e| Dir.glob("#{e}/*.cr").map{|i| i[(e.size+1)..-4]} }
                                  .flatten
      paths.map do |path|
        CompletionItem.new(path, CompletionItemKind::File, path)
      end
    end

  end

  class Completion
    METHOD_CALL_REGEX = /(?<target>[a-zA-Z][a-zA-Z_:]*)\.(?<method>[a-zA-Z]*[a-zA-Z_:]*)$/
    INSTANCE_VARIABLE_REGEX = /(?<var>@[a-zA-Z_]*)$/
    IMPORT_MODULE_REGEX = /require\s*\"(?<import>[a-zA-Z\/._]*)$/
    def initialize(@text_document : TextDocument, @context : CompletionContext | Nil, @position : Position)
    end

    def run
      context = parse_context
      context.find
    end

    def parse_context
      line = @text_document.text.first.lines[@position.line][0..@position.character - 1]
      case line
      when METHOD_CALL_REGEX
        InstanceMethodCallContext.new($~["target"], $~["method"], line , @text_document)
      when INSTANCE_VARIABLE_REGEX
        InstanceVariableContext.new($~["var"], line, @text_document)
      when IMPORT_MODULE_REGEX
        ImportModuleContext.new($~["import"], @text_document)
      else
        raise UnrecognizedContext.new("Couldn't identify context of: #{line}")
      end
    end
  end
end
