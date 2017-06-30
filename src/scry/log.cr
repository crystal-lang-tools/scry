require "logger"

module Scry
  class Log
    private def self.initialize_logger
      log_filename = File.expand_path(".scry.out", Dir.current)
      log_file = File.open(log_filename, "w")
      logger = Logger.new(log_file)
      logger.level = Logger::DEBUG
      logger
    end

    @@logger : Logger = initialize_logger

    def self.logger
      @@logger
    end
  end
end
