require "json"
require "./settings"

module Scry

  struct DidChangeConfigurationParams
    JSON.mapping({
      settings: Settings
    }, true)
  end

end
