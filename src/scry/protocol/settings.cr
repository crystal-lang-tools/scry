require "json"

module Scry
  struct Settings
    JSON.mapping({
      crystal_config: {type: Customizations, key: /^crystal.*/, default: Customizations.from_json("{}")},
    })
  end

  struct Customizations
    JSON.mapping({
      max_number_of_problems: {type: Int32, key: "maxNumberOfProblems", default: 100},
      backend:                {type: String, default: "scry"},
      custom_command:         {type: String, key: "customCommand", default: "scry"},
      custom_command_args:    {type: Array(String), key: "customCommandArgs", default: [] of String},
      log_level:              {type: String, key: "logLevel", default: "info"},
    })
  end
end
