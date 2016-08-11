require "../spec_helper"
require "json"

module Scry

  describe UpdateConfig do

    it "updates the maximum number of problems to report" do
      workspace = Workspace.new("/foo", 1.to_i64, 10)
      updater = UpdateConfig.new(
        workspace,
        DidChangeConfigurationParams.from_json(
          String.build { |io|
            io.json_object do |params|
              params.field "settings" do
                io.json_object do |settings|
                  settings.field "crystal-ide" do
                    io.json_object do |crystal_ide|
                      crystal_ide.field "maxNumberOfProblems", 20
                    end
                  end
                end
              end
            end
          }
        )
      )
      changed, _response = updater.run
      changed.max_number_of_problems.should eq(20)
    end
  end

end
