require "json"

module Scry
  # Language Server Protocol doesn't specify settings type
  # because it depend of client.
  # See: https://github.com/Microsoft/language-server-protocol/blob/master/protocol.md#didchangeconfiguration-notification
  #
  # Replace the key to match your client config.
  struct Settings
    JSON.mapping({
      crystal_config: {type: Customizations, key: "crystal-lang"},
    }, true)
  end

  # Replace mappings to match your client config,
  # also you need to rename attributes in all the project.
  #
  # Currently configured for vscode-crystal-lang
  struct Customizations
    JSON.mapping(
      max_number_of_problems: {type: Int32, key: "maxNumberOfProblems"},
      log_level: {type: String, key: "logLevel"}
    )
  end
end
