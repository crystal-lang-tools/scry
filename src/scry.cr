require "./scry/*"
require "./scry/protocol/*"
require "logger"
require "json"

module Scry
  extend self

  def start

    Log.logger.info { "Scry is looking into your code..." }

    EnvironmentConfig.new.run

    context = Context.new

    loop do
      content = Request.new(STDIN).read
      request = Message.new(content).parse
      results = context.dispatch(request)
      response = Response.new([results].flatten)
      response.write(STDOUT)
    end

    Log.logger.info { "...your session has ended" }
  rescue ex
    Log.logger.error {
      (ex.message || "Unknown error") + "\n" + ex.backtrace.join("\n")
    } unless Log.logger.nil?
  ensure
    Log.logger.close unless Log.logger.nil?
  end

end

Scry.start

