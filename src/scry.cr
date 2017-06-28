require "./scry/*"
require "./scry/protocol/*"
require "logger"
require "json"

module Scry
  extend self

  def start

    Log.logger.info { "Scry is looking into your code..." }
    at_exit do
      Log.logger.info { "...your session has ended" }
    end

    EnvironmentConfig.new.run

    context = Context.new
    
    loop do
      begin
        content = Request.new(STDIN).read
        request = Message.new(content).parse
        results = context.dispatch(request)
      rescue ex
        results = [ErrorMessage.new(ex)]
      ensure
        Log.logger.info { GC.stats }
        response = Response.new([results].flatten)
        response.write(STDOUT)
      end
    end
  rescue ex
    Log.logger.error {
      (ex.message || "Unknown error") + "\n" + ex.backtrace.join("\n")
    } unless Log.logger.nil?
  ensure
    Log.logger.close unless Log.logger.nil?
  end

end

Scry.start
