require "./protocol/*"

module Scry

  class Workspace
    property root_path : String
    property process_id : Int64
    property max_number_of_problems : Int32

    def initialize(root_path, process_id, max_number_of_problems)
      @root_path = root_path
      @process_id = process_id
      @max_number_of_problems = max_number_of_problems
    end

  end

end
