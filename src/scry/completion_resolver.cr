module Scry
  class CompletionResolver
    def initialize(@id : Int32, @completion_item : LSP::Protocol::CompletionItem)
    end

    def run
      data = @completion_item.data
      case data
      when LSP::Protocol::RequireModuleContextData
        file = File.new data.path
        doc = file.each_line.first(5).join("\n")
        @completion_item.documentation = LSP::Protocol::MarkupContent.new("markdown", "```crystal\n#{doc}\n```")
        @completion_item
      when LSP::Protocol::MethodCallContextData
        file = File.new data.path
        line = data.location.not_nil!.split(":")[1].to_i
        lines = file.each_line.first(line - 1).to_a.reverse.take_while(&.match /^\s*#/).map { |e| e.gsub(/^\s*#/, "") }.reverse.join("\n")
        @completion_item.documentation = LSP::Protocol::MarkupContent.new("markdown", lines)
        @completion_item
      else
        @completion_item
      end
    end
  end
end
