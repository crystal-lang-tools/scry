require "./file_event"

module Scry
  struct DidChangeWatchedFilesParams
    JSON.mapping({
      changes: Array(FileEvent),
    }, true)
  end
end
