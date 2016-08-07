require "json"

module Scry

  struct DidChangeWatchedFilesParams
    JSON.mapping({
      changes: Array(FileEvent)
    })
  end

end