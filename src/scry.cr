require "./scry/*"
require "./scry/protocol/*"
require "logger"
require "json"

module Scry
  extend self

  def send_response(io, result, rpc : RemoteProcedureCall)
    json = create_response(rpc.id, result.to_json)
    out = Response.new(json).to_s

    Log.logger.debug { "SENT Response: #{out}" }
    io << out
    io.flush
  end

  def send_response(io, results : Array(PublishDiagnosticsNotification), rpc)
    results.each do |notification|
      Log.logger.debug(notification.to_json)
      out = Response.new(notification.to_json).to_s

      Log.logger.debug { "SENT Notification: #{out}" }
      io << out
    end
    io.flush
  end

  def send_response(io, result, rpc)
    # Some things don't get responses
  end

  def create_response(id, json)
    "{ \"jsonrpc\": \"2.0\", \"id\": \"#{id}\", \"result\": #{json} }"
  end

  def start

    Log.logger.info { "Scry is looking into your code..." }

    EnvironmentConfig.new.run

    context = Context.new

    loop do
      content = Request.new(STDIN).read
      request = Procedure.new(content).parse
      result = context.dispatch(request)
      send_response(STDOUT, result, request)
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

