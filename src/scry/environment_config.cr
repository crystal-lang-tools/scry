module Scry

  class EnvironmentConfig

    @config : Hash(String, String)

    def initialize
      @config = initialize_from_crystal_env
    end

    def run
      @config.each do |k, v|
        ENV[k] = v
      end
    end

    private def initialize_from_crystal_env
      crystal_env
        .lines
        .map { |line| line.split("=") }
        .map { |pair| Tuple(String, String).from(pair) }
        .reduce(Hash(String, String).new) { |memo, (k, v)|
          memo[k] = v.chomp[1..-1]
          memo
        }
    end

    private def crystal_env
      String.build { |io|
        Process.run("crystal", ["env"], output: io)
      }
    end

  end

end
