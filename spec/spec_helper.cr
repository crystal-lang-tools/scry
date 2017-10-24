require "spec"
require "../src/scry/**"

module Scry
  EnvironmentConfig.new.run

  SOME_FILE_PATH = File.expand_path("./fixtures/some_file.cr", __DIR__)

  INITIALIZATION_EXAMPLE = %({ "jsonrpc": "2.0", "id": 1, "method": "initialize", "params": { "processId": 1, "rootPath": "/foo", "capabilities": {} , "trace": "off"}})

  CONFIG_CHANGE_EXAMPLE = %({"jsonrpc":"2.0","method":"workspace/didChangeConfiguration","params":{"settings":{"crystal-ide":{"maxNumberOfProblems":100,"backend":"scry","customCommand":"crystal","customCommandArgs":[],"logLevel":"debug"}}}})

  DOC_OPEN_EXAMPLE = %({"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///Users/foo/Projects/crystal_av/src/crystal_av/c_handler.cr","languageId":"crystal","version":1,"text":"put \\"hello\\"; Thing.new"}}})

  DOC_CLOSE_EXAMPLE = %({"jsonrpc":"2.0","method":"textDocument/didClose","params":{"textDocument":{ "uri":"file://#{SOME_FILE_PATH}" }}})

  DOC_CHANGE_EXAMPLE = %({"jsonrpc":"2.0","method":"textDocument/didChange","params":{"textDocument":{"version":808,"uri":"file://#{SOME_FILE_PATH}"},"contentChanges":[{"text":"module Scry\\n\\n  put this\\n"}]}})

  DID_SAVE_EXAMPLE = %({"jsonrpc":"2.0","method":"textDocument/didSave","params":{"textDocument":{ "uri":"file://#{SOME_FILE_PATH}" }}})

  WATCHED_FILE_CHANGED_EXAMPLE = %({"jsonrpc":"2.0","method":"workspace/didChangeWatchedFiles","params":{"changes":[{"uri":"file://#{SOME_FILE_PATH}","type":2}]}})

  WATCHED_FILE_DELETED_EXAMPLE = %({"jsonrpc":"2.0","method":"workspace/didChangeWatchedFiles","params":{"changes":[{"uri":"file://#{SOME_FILE_PATH}","type":3}]}})

  SHUTDOWN_EXAMPLE = %({"jsonrpc":"2.0","id":1,"method":"shutdown"})

  BUILD_ERROR_EXAMPLE = %({"file":"/home/aa.cr","line":4,"column":1,"size":1,"message":"Oh no!, an Error"})

  FORMATTER_RESPONSE_EXAMPLE = %({"jsonrpc":"2.0","result":[{"range":{"start":{"line":0,"character":0},"end":{"line":1,"character":6}},"newText":"1 + 1\\n"}]})

  TEXTDOCUMENT_POSITION_PARAM_EXAMPLE = %({"textDocument":{"uri":"#{SOME_FILE_PATH}"},"position":{"line":4,"character":2}})

  INITIALIZED_EXAMPLE = %({"jsonrpc": "2.0", "method": "initialized", "params": {}})
end
