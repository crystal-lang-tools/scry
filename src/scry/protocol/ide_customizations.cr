require "json"

module Scry

  struct IDECustomizations
    JSON.mapping({
      max_number_of_problems: { type: Int32, key: "maxNumberOfProblems" },
      backend: String,
      custom_command: { type: String, key: "customCommand" },
      custom_command_args: { type: Array(String), key: "customCommandArgs" },
      log_level: { type: String, key: "logLevel" }
    }, true)
  end

end
