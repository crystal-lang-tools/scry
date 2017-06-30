require "compiler/crystal/**"

require "./log"
require "./protocol/location"

module Scry
  # Using Crystal implementation to emulate GoTo Definition.
  struct Implementations
    def initialize(@text_document : TextDocument)
    end

    def run
      if position = @text_document.position
        search(
          @text_document.filename,
          @text_document.text.first,
          position
        )
      end
    end

    # NOTE: compiler is a bit heavy in some projects.
    def search(filename, source, position)
      source = Crystal::Compiler::Source.new(filename, source)
      compiler = Crystal::Compiler.new
      compiler.color = false
      compiler.no_codegen = true
      compiler.debug = Crystal::Debug::None
      result = compiler.compile(source, filename + ".out")
      loc = Crystal::Location.new(filename, position.line + 1, position.character + 1)
      res = Crystal::ImplementationsVisitor.new(loc).process(result)
      Log.logger.debug(res)
      impls = res.implementations
      if res.status == "ok" && impls
        locations = impls.map do |impl|
          pos = Position.new(impl.line, impl.column)
          range = Range.new(pos, pos)
          Location.new("file://" + impl.filename, range)
        end
        ResponseMessage.new(@text_document.id, locations)
      end
    end
  end
end
