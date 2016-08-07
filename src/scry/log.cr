require "logger"

module Scry

  class Log

    def self.logger
      @@logger ||= initialize_logger as Logger
    end

    private def self.initialize_logger
      log_filename = File.expand_path("../../scry.out", __DIR__)
      log_file = File.open(log_filename, "w")
      logger = Logger.new(log_file)
      logger.level = Logger::DEBUG
      logger
    end

  end

end