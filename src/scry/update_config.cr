require "./workspace"

module Scry

  class UpdateConfig

    LOG_LEVELS = {
      "debug" => Logger::DEBUG,
      "info"  => Logger::INFO,
      "warn"  => Logger::WARN,
      "error" => Logger::ERROR,
      "fatal" => Logger::FATAL
    }

    private getter! workspace : Workspace
    private getter! settings : DidChangeConfigurationParams

    def initialize(@workspace : Workspace, @settings : DidChangeConfigurationParams)
    end

    def initialize(@workspace : Workspace, settings)
      raise "Can't update settings with #{settings.inspect}"
    end

    def run
      workspace.max_number_of_problems =
        ide_customizations.max_number_of_problems

      Log.logger.level = log_level(ide_customizations.log_level)

      { workspace, nil }
    end

    private def ide_customizations
      settings.settings.crystal_ide
    end

    private def log_level(level : String)
      LOG_LEVELS[level]
    end

  end

end
