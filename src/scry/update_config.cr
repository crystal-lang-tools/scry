require "./log"
require "./workspace"
require "./protocol/did_change_configuration_params"

module Scry
  struct UpdateConfig
    LOG_LEVELS = {
      "debug" => Logger::DEBUG,
      "info"  => Logger::INFO,
      "warn"  => Logger::WARN,
      "error" => Logger::ERROR,
      "fatal" => Logger::FATAL,
    }

    def initialize(@workspace : Workspace, @settings : DidChangeConfigurationParams)
    end

    def initialize(@workspace : Workspace, @settings)
      raise "Can't update settings with #{settings.inspect}"
    end

    def run
      @workspace.max_number_of_problems = customizations.max_number_of_problems
      Log.logger.level = log_level(customizations.log_level || "error")
      Log.logger.info("Scry Configuration Updated:\n #{@settings.to_json}")
      {@workspace, nil}
    end

    private def customizations
      @settings.settings.crystal_config
    end

    private def log_level(level : String)
      LOG_LEVELS[level]
    end
  end
end
