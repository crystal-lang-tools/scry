require "json"

module Scry

  struct IDECustomizations
    JSON.mapping({
      max_number_of_problems: { type: Int32, key: "problemsLimit" },
      backend: { type: String, default: "scry" },
      custom_command: { type: String, key: "customCommand", default: "" },
      custom_command_args: { type: Array(String), key: "customCommandArgs", default: Array(String).new },
      log_level: { type: String, key: "logLevel", default: "error" }
    })
  end

end
