require "json"

module Scry

  struct FileEvent
    JSON.mapping({
      uri: String,
      type: Int32
    })
  end

end