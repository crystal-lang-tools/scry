module LSP::Protocol
  alias Settings = SettingsCrystalIDE | SettingsCrystalLang

  struct Customizations
    include JSON::Serializable
    @[JSON::Field(key: "maxNumberOfProblems")]
    property max_number_of_problems : Int32 = 100
    @[JSON::Field(key: "scry")]
    property backend : String = "scry"
    @[JSON::Field(key: "customCommand")]
    property custom_command : String = "scry"
    @[JSON::Field(key: "customCommandArgs")]
    property custom_command_args : Array(String) = [] of String
    @[JSON::Field(key: "logLevel")]
    property log_level : String = "info"
  end

  # Configuration for vscode-crystal-ide
  # https://github.com/kofno/crystal-ide
  struct SettingsCrystalIDE
    include JSON::Serializable

    @[JSON::Field(key: "crystal-ide")]
    property crystal_config : Customizations
  end

  # Configuration for vscode-crystal-lang
  # https://github.com/faustinoaq/vscode-crystal-lang
  struct SettingsCrystalLang
    include JSON::Serializable

    @[JSON::Field(key: "crystal-lang")]
    property crystal_config : Customizations
  end
end
