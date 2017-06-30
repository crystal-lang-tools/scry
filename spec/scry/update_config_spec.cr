require "../spec_helper"

module Scry
  describe UpdateConfig do
    it "updates the maximum number of problems to report" do
      workspace = Workspace.new("/foo", 1.to_i64, 10)
      updater = UpdateConfig.new(
        workspace,
        DidChangeConfigurationParams.from_json(
          JSON.build do |params|
            params.object do
              params.field "settings" do
                params.object do
                  params.field "crystal-ide" do
                    params.object do
                      params.field "backend", "scry"
                      params.field "maxNumberOfProblems", 20
                      params.field "customCommand", "crystal"
                      params.field "customCommandArgs" do
                        params.array do
                        end
                      end
                      params.field "logLevel", "debug"
                    end
                  end
                end
              end
            end
          end
        )
      )
      changed, _response = updater.run
      changed.max_number_of_problems.should eq(20)
    end
  end
end
