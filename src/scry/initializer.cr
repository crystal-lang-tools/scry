require "./log"
require "./workspace"
require "./protocol/initialize_params"
require "./protocol/server_capabilities"

module Scry
  struct Initializer
    def initialize(params : InitializeParams, @msg_id : Int32)
      @workspace = Workspace.new(
        root_uri: params.root_uri,
        process_id: params.process_id,
        max_number_of_problems: 100
      )
      ENV["CRYSTAL_PATH"] = %(#{@workspace.root_uri}/lib:#{ENV["CRYSTAL_PATH"]})
    end

    def run
      @workspace.open_workspace
      {@workspace, response}
    end

    private def response
      Initialize.new(@msg_id)
    end
  end
end
