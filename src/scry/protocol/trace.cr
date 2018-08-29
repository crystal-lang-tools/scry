require "json"

module Scry::Protocol
  # The initial trace setting. If omitted trace is disabled ('off')
  # 'off' | 'messages' | 'verbose'
  struct Trace
    JSON.mapping({
      value: String,
    }, true)
  end
end
