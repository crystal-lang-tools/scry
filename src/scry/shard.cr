require "yaml"

module Scry
  class Shard
    property dependencies : Array(String)

    def initialize(@file_path : String)
      @dependencies = [] of String

      yaml = YAML.parse(File.read(@file_path))
      process_dependencies(yaml)
      process_dependencies(yaml, "development_dependencies")
    end

    private def process_dependencies(yaml, key = "dependencies")
      deps = yaml[key]?
      return unless deps
      deps.as_h.each do |k, _|
        @dependencies << k.to_s
      end
    end
  end
end
