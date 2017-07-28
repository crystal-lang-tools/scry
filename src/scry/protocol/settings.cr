require "json"

# Add new configuration type on did_change_configuration_params.cr:6
module Scry
  # Configuration for vscode-crystal-ide
  # https://github.com/kofno/crystal-ide
  struct SettingsCrystalIDE
    JSON.mapping({
      crystal_config: {type: CustomizationsCrystalIDE, key: "crystal-ide"},
    })
  end

  # :ditto:
  struct CustomizationsCrystalIDE
    JSON.mapping({
      max_number_of_problems: {type: Int32, key: "maxNumberOfProblems"},
      backend:                String,
      custom_command:         {type: String, key: "customCommand"},
      custom_command_args:    {type: Array(String), key: "customCommandArgs"},
      log_level:              {type: String, key: "logLevel"},
    })
  end

  # Configuration for vscode-crystal-lang
  # https://github.com/faustinoaq/vscode-crystal-lang
  struct SettingsCrystalLang
    JSON.mapping({
      crystal_config: {type: CustomizationsCrystalLang, key: "crystal-lang"},
    })
  end

  # :ditto:
  struct CustomizationsCrystalLang
    JSON.mapping({
      max_number_of_problems: {type: Int32, key: "maxNumberOfProblems"},
      log_level:              {type: String, key: "logLevel"},
    })
  end

  # Configuration for atom-crystal
  # https://github.com/atom-crystal/scry
  # struct SettingsAtomCrystal
  #   JSON.mapping({
  #     crystal_config: {type: CustomizationsAtomCrystal, key: "atom-crystal"},
  #   })
  # end

  # :ditto:
  # struct CustomizationsAtomCrystal
  #   JSON.mapping({
  #     max_number_of_problems: {type: Int32, key: "maxNumberOfProblems"},
  #     log_level:              {type: String, key: "logLevel"},
  #   })
  # end
end
