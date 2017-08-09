require "logger"
require "tempfile"

module Scry
  class Log
    private def self.initialize_logger
      tmpfile = Tempfile.new("scry.out")
      log_file = File.open(tmpfile.path, "w")
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
