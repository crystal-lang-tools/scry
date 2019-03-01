module Scry
  module EnvironmentConfig
    def self.run
      initialize_from_crystal_env.each do |k, v|
        ENV[k] = v
      end
    end

    private def self.initialize_from_crystal_env
      crystal_env
        .lines
        .map(&.split('='))
        .map { |(k, v)| {k, v.chomp[1..-2]} }
        .to_h
    end

    private def self.crystal_env
      String.build do |io|
        Process.run("crystal", ["env"], output: io)
      end
    end
  end
end
