require "./workspace"

module Scry

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
