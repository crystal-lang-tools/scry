require "json"

module Scry

  struct DidChangeConfigurationParams
    JSON.mapping({
      settings: Settings
    }, true)
  end

  struct Settings
    JSON.mapping({
      crystalIDE: { type: IDECustomizations, key: "crystal-ide" }
    }, true)
  end

  struct IDECustomizations
    JSON.mapping({
      max_number_of_problems: { type: Int32, key: "maxNumberOfProblems" }
    }, true)
  end

end