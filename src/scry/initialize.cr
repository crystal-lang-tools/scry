require "./workspace"

module Scry

  class Initialize

    private getter workspace : Workspace

    def initialize(params : InitializeParams, @msg_id : Int32)
      @workspace = Workspace.new(
        root_path: params.root_path,
        process_id: params.process_id,
        max_number_of_problems: 100
      )
    end

    def run
      { @workspace, response }
    end

    private def response
      ServerCapabilities.new(@msg_id)
    end

  end

end
