module Scry::Protocol
  struct DidChangeWatchedFilesParams
    JSON.mapping({
      changes: Array(FileEvent),
    }, true)
  end
end
