module LSP::Protocol
  enum FileEventType
    Created = 1
    Changed = 2
    Deleted = 3
  end

  struct FileEvent
    JSON.mapping({
      uri:  String,
      type: FileEventType,
    }, true)
  end
end
