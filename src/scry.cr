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

    next_request = Channel(Nil).new
    context = Context.new

    loop do
      content = Request.new(STDIN).read
      spawn do
        request = Message.new(content).parse
        results = context.dispatch(request)
      rescue ex
        results = [ResponseMessage.new(ex)]
      ensure
        response = Response.new([results].flatten)
        response.write(STDOUT)
        next_request.send nil
      end
      select
      when next_request.receive
        Log.logger.info("Scry has processed a request!")
        next
      else
        sleep 1
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
