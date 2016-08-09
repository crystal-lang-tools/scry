require "json"
require "./file_event"

module Scry

  struct DidChangeWatchedFilesParams
    JSON.mapping({
      changes: Array(FileEvent)
    })
  end

end