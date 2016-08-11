require "json"

module Scry

  enum FileEventType
    Created = 1
    Changed
    Deleted
  end

  struct FileEvent
    JSON.mapping({
      uri: String,
      type: FileEventType
    })
  end

end