require "./scry/log"
require "./scry/request"
require "./scry/context"
require "./scry/message"
require "./scry/response"
require "./scry/environment_config"
require "./scry/concurrent_rpc"

module Scry
  def self.start
    Log.logger.info("Scry is looking into your code...")
    EnvironmentConfig.new.run
    ConcurrentRpc.new.run
  end
end

Scry.start
