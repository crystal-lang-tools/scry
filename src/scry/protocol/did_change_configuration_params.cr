require "./settings"

module Scry
  struct DidChangeConfigurationParams
    JSON.mapping({
      settings: SettingsCrystalIDE | SettingsCrystalLang,
    }, true)
  end
end
