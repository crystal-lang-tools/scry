module Scry
  struct Workspace
    property root_uri : String
    property process_id : Int32 | Int64
    property max_number_of_problems : Int32

    def initialize(root_uri, process_id, max_number_of_problems)
      @root_uri = root_uri
      @process_id = process_id
      @max_number_of_problems = max_number_of_problems
    end
  end
end
