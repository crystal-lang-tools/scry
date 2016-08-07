module Scry

  struct DidChangeConfigurationParams
    JSON.mapping({
      settings: Settings
    }, true)
  end

  struct Settings
    JSON.mapping({
      crystal_ide: { type: IDECustomizations, key: "crystal-ide" }
    }, true)
  end

  struct IDECustomizations
    JSON.mapping({
      max_number_of_problems: { type: Int32, key: "maxNumberOfProblems" }
    }, true)
  end

  class UpdateConfig

    private getter! workspace : Workspace
    private getter! settings : DidChangeConfigurationParams

    def initialize(@workspace : Workspace, @settings : DidChangeConfigurationParams)
    end

    def initialize(@workspace : Workspace, settings)
      raise "Can't update settings with #{settings.inspect}"
    end

    def run
      workspace.max_number_of_problems =
        ide_customizations.max_number_of_problems

      { workspace, nil }
    end

    private def ide_customizations
      settings.settings.crystal_ide
    end

  end

end