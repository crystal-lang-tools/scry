require "logger"
require "tempfile"

module Scry
  class Log
    private def self.initialize_logger
      log_file = Tempfile.new("scry.out")
      logger = Logger.new(log_file.path)
      logger.level = Logger::DEBUG
      logger
    end

    @@logger : Logger = initialize_logger

    def self.logger
      @@logger
    end
  end
end
