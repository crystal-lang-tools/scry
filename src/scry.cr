require "./scry/protocol"
require "./scry/log"
require "./scry/request"
require "./scry/context"
require "./scry/message"
require "./scry/environment_config"
require "./scry/client"

module Scry
  def self.start
    client = Client.new(STDOUT)
    Log.logger = Log::ClientLogger.new(client)

    Log.logger.info("Scry is looking into your code...")

    at_exit do
      Log.logger.info("...your session has ended")
    end

    EnvironmentConfig.new.run

    context = Context.new
    loop do
      content = Request.new(STDIN).read
      request = Message.new(content).parse
      begin
        results = context.dispatch(request)
      rescue ex
        results = process_error(request, ex)
      ensure
        response = [results].flatten.compact
        client.send_message(response)
      end
    end
  rescue ex
    Log.logger.error(
      %(#{ex.message || "Unknown error"}\n#{ex.backtrace.join('\n')})
    ) unless Log.logger.nil?
  ensure
    Log.logger.close unless Log.logger.nil?
  end

  def self.process_error(request : Protocol::RequestMessage, error)
    Protocol::ResponseMessage.new(request.id, error)
  end

  def self.process_error(request : Protocol::NotificationMessage, error)
    Log.logger.error(%(#{error.message}\n#{error.backtrace.join('\n')}))
    nil
  end
end

Scry.start
