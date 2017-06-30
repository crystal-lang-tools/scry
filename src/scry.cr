require "./scry/log"
require "./scry/request"
require "./scry/context"
require "./scry/message"
require "./scry/response"
require "./scry/environment_config"

module Scry
  def self.start
    Log.logger.info("Scry is looking into your code...")

    at_exit do
      Log.logger.info("...your session has ended")
    end

    EnvironmentConfig.new.run

    context = Context.new
    loop do
      begin
        content = Request.new(STDIN).read
        request = Message.new(content).parse
        results = context.dispatch(request)
      rescue ex
        results = [ResponseMessage.new(ex)]
      ensure
        response = Response.new([results].flatten)
        response.write(STDOUT)
      end
    end
  rescue ex
    Log.logger.error(
      %(#{ex.message || "Unknown error"}\n#{ex.backtrace.join('\n')})
    ) unless Log.logger.nil?
  ensure
    Log.logger.close unless Log.logger.nil?
  end
end

Scry.start
