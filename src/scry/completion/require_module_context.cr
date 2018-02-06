module Scry::Completion
  class RequireModuleContext < Context
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
        data = Scry::RequireModuleContextData.new(path)
        CompletionItem.new(module_name, CompletionItemKind::Module, module_name, data).as(CompletionItem)
      end
    end

    def find_module(path)
      paths = Crystal::CrystalPath.default_path.split(":")
                                               .select { |e| File.exists?(e) }
                                               .flat_map do |e|
        Dir.glob("#{e}/#{path}*/*.cr").map { |i| [i, i[(e.size + 1)..-4]] }.as(Array(Array(String)))
      end
      paths.map do |path_module_name|
        path, module_name = path_module_name
        data = Scry::RequireModuleContextData.new(path)
        CompletionItem.new(module_name, CompletionItemKind::Module, "module #{module_name}", data).as(CompletionItem)
      end
    end
  end
end
