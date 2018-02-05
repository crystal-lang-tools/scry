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
      case @import
      when /^\./
        find_relative(@import)
      else
        find_module(@import)
      end
    end

    def find_relative(path)
      file_dir = File.dirname(@text_document.filename)
      path_glob = File.expand_path(path, file_dir)
      paths = Dir.glob(["#{path_glob}*/*.cr", "#{path_glob}*.cr"]).map do |i|
        [i, i[(file_dir.size + 1)..-4]]
      end
      paths.map do |path_module_name|
        path, module_name = path_module_name
        data = JSON.parse({"path": path, "type": "import_module_context"}.to_json)
        CompletionItem.new(module_name, CompletionItemKind::Module, module_name, data).as(CompletionItem)
      end
    end

    def find_module(path)
      paths = Crystal::CrystalPath.default_path.split(":")
                                  .select{|e| File.exists?(e)}
                                  .flat_map do |e|
                                    Dir.glob("#{e}/#{path}*/*.cr").map { |i| [i, i[(e.size+1)..-4]]}.as(Array(Array(String)))
                                  end
       paths.map do |path_module_name|
        path, module_name = path_module_name
        data = JSON.parse({"path": path, "type": "import_module_context"}.to_json)
        CompletionItem.new(module_name, CompletionItemKind::Module, "module #{module_name}", data).as(CompletionItem)
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

    def self.resolve(params : CompletionItem)
      data = params.data.as(JSON::Any)
      if(data["type"] == "import_module_context")
        path = data["path"].as_s
        file = File.new(path)
        doc = file.each_line.first(5).join("\n")
        params.documentation = MarkupContent.new("markdown", "```crystal \n#{doc} \n ```")
        params
      end
    end
  end
end
