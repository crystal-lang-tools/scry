require "json"

module Scry

  struct IDECustomizations
    JSON.mapping({
      max_number_of_problems: { type: Int32, key: "maxNumberOfProblems" }
    }, true)
  end

end
