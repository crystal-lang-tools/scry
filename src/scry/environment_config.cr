module Scry
  module EnvironmentConfig
    private enum EnvVars
      CRYSTAL_CACHE_DIR
      CRYSTAL_PATH
      CRYSTAL_VERSION
      CRYSTAL_LIBRARY_PATH
      CRYSTAL_OPTS
    end

    def self.run
      initialize_from_crystal_env.each_with_index do |v, i|
        e = EnvVars.from_value(i).to_s
        ENV[e] = v
      end
    end

    private def self.initialize_from_crystal_env
      crystal_env
        .lines
        .to_a
    end

    private def self.crystal_env
      String.build do |io|
        Process.run("crystal", ["env"] + EnvVars.names, output: io)
      end
    end
  end
end
