module Scry::Completion
  class RequireModuleContext < Context
    RELATIVE_IMPORT_REGEX = /^\./
    def initialize(@import : String, @text_document : TextDocument)
    end

    def find
      case @import
      when RELATIVE_IMPORT_REGEX
        file_dir = File.dirname(@text_document.filename)
        complete_in([file_dir])
      else
        lookup_paths = ENV["CRYSTAL_PATH"].split(":")
        complete_in(lookup_paths)
      end
    end

    def complete_in(paths)
      found_paths = paths.flat_map do |root_path|
        Dir.glob("#{root_path}/#{@import}*/", "#{root_path}/#{@import}*.cr").map{|e| File.expand_path(e)} - [@text_document.filename]
      end
      found_paths.map do |path|
        label = File.directory?(path) ? File.basename(path)+"/" : File.basename(path, ".cr")
        insert_text = label
        root_path = paths.first
        CompletionItem.new(
          label: label,
          insert_text: insert_text,
          kind: CompletionItemKind::Module,
          detail: label,
          data: RequireModuleContextData.new(path)
        )
      end
    end
  end
end
