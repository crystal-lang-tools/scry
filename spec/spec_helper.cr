require "spec"
require "../src/scry/environment_config"


module Scry

  EnvironmentConfig.new.run

  SOME_FILE_PATH = File.expand_path("./fixtures/some_file.cr", __DIR__)

  INITIALIZATION_EXAMPLE =
    %({ "jsonrpc": "2.0", "id": 1, "method": "initialize", "params": { "processId": 1, "rootPath": "/foo", "capabilities": {} , "trace": "off"}})

  CONFIG_CHANGE_EXAMPLE =
    %({"jsonrpc":"2.0","method":"workspace/didChangeConfiguration","params":{"settings":{"crystal-ide":{"maxNumberOfProblems":100,"backend":"scry","customCommand":"crystal","customCommandArgs":[],"logLevel":"debug"}}}})

  DOC_OPEN_EXAMPLE =
    %({"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///Users/foo/Projects/crystal_av/src/crystal_av/c_handler.cr","languageId":"crystal","version":1,"text":"put \\"hello\\"; Thing.new"}}})

  DOC_CHANGE_EXAMPLE =
    %({"jsonrpc":"2.0","method":"textDocument/didChange","params":{"textDocument":{"version":808,"uri":"file://#{SOME_FILE_PATH}"},"contentChanges":[{"text":"module Scry\\n\\n  put this\\n"}]}})

  WATCHED_FILE_CHANGED_EXAMPLE =
    %({"jsonrpc":"2.0","method":"workspace/didChangeWatchedFiles","params":{"changes":[{"uri":"file://#{SOME_FILE_PATH}","type":2}]}})

  WATCHED_FILE_DELETED_EXAMPLE =
    %({"jsonrpc":"2.0","method":"workspace/didChangeWatchedFiles","params":{"changes":[{"uri":"file://#{SOME_FILE_PATH}","type":3}]}})

  SHUTDOWN_EXAMPLE = %({"jsonrpc":"2.0","id":1,"method":"shutdown"})

end
