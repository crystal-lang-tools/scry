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

    next_request = Channel(Int32).new(10)
    context = Context.new

    loop do |i|
      spawn do
        Log.logger.debug("Scry is listening request ##{i}...")
        content = Request.new(STDIN).read
        request = Message.new(content).parse
        results = context.dispatch(request)
      rescue ex
        results = [ResponseMessage.new(ex)]
      ensure
        response = Response.new([results].flatten)
        response.write(STDOUT)
        next_request.send i
      end

      select
      when n = next_request.receive
        Log.logger.debug("Scry has processed request ##{n}!")
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
