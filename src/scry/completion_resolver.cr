module Scry
  class CompletionResolver
    def initialize(@id : Int32, @completionItem : CompletionItem)
    end

    def run
      data = @completionItem.data
      case data
      when RequireModuleContextData
        file = File.new data.path
        doc = file.each_line.first(5).join("\n")
        @completionItem.documentation = MarkupContent.new("markdown", "```crystal \n#{doc} \n ```")
        @completionItem
      end
    end
  end
end
