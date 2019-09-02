require "spec"
require "lsp"
require "../src/scry/**"
require "./protocol_helper"

module Scry
  EnvironmentConfig.run
  ROOT_PATH      = File.expand_path("spec/fixtures/")
  SOME_FILE_PATH = File.expand_path("./fixtures/src/some_file.cr", __DIR__)

  INITIALIZATION_EXAMPLE = %({ "jsonrpc": "2.0", "id": 1, "method": "initialize", "params": { "processId": 1, "rootPath": "#{ROOT_PATH}", "capabilities": {} , "trace": "off"}})

  CONFIG_CHANGE_EXAMPLE = %({"jsonrpc":"2.0","method":"workspace/didChangeConfiguration","params":{"settings":{"crystal-lang":{"maxNumberOfProblems":100,"backend":"scry","customCommand":"crystal","customCommandArgs":[],"logLevel":"debug"}}}})

  DOC_OPEN_EXAMPLE = %({"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file://#{SOME_FILE_PATH}","languageId":"crystal","version":1,"text":"put \\"hello\\"; Thing.new"}}})

  DOC_CLOSE_EXAMPLE = %({"jsonrpc":"2.0","method":"textDocument/didClose","params":{"textDocument":{ "uri":"file://#{SOME_FILE_PATH}" }}})

  DOC_CHANGE_EXAMPLE = %({"jsonrpc":"2.0","method":"textDocument/didChange","params":{"textDocument":{"version":808,"uri":"file://#{SOME_FILE_PATH}"},"contentChanges":[{"text":"module Scry\\n\\n  put this\\n"}]}})

  DID_SAVE_EXAMPLE = %({"jsonrpc":"2.0","method":"textDocument/didSave","params":{"textDocument":{ "uri":"file://#{SOME_FILE_PATH}" }}})

  WATCHED_FILE_CHANGED_EXAMPLE = %({"jsonrpc":"2.0","method":"workspace/didChangeWatchedFiles","params":{"changes":[{"uri":"file://#{SOME_FILE_PATH}","type":2}]}})

  WATCHED_FILE_DELETED_EXAMPLE = %({"jsonrpc":"2.0","method":"workspace/didChangeWatchedFiles","params":{"changes":[{"uri":"file://#{SOME_FILE_PATH}","type":3}]}})

  SHUTDOWN_EXAMPLE = %({"jsonrpc":"2.0","id":1,"method":"shutdown"})

  BUILD_ERROR_EXAMPLE = %({"file":"/home/aa.cr","line":4,"column":1,"size":1,"message":"Oh no!, an Error","source":"Scry"})

  FORMATTER_RESPONSE_EXAMPLE = %({"jsonrpc":"2.0","id":null,"result":[{"range":{"start":{"line":0,"character":0},"end":{"line":1,"character":6}},"newText":"1 + 1\\n"}]})

  TEXTDOCUMENT_POSITION_PARAM_EXAMPLE = %({"textDocument":{"uri":"#{SOME_FILE_PATH}"},"position":{"line":4,"character":2}})

  INITIALIZED_EXAMPLE = %({"jsonrpc": "2.0", "method": "initialized", "params": {}})

  COMPLETION_EXAMPLE = %({"jsonrpc": "2.0", "method": "textDocument/completion", "params": #{TEXTDOCUMENT_POSITION_PARAM_EXAMPLE}})

  UNTITLED_FORMATTER_EXAMPLE = %({"textDocument":{"uri":"untitled:Untitled-1","languageId":"crystal","version":1,"text":"1+1"}})
end

def get_example_textDocument_message_json(method : String, uri : String) : String
  %({"jsonrpc":"2.0","method":"#{method}","params":{"textDocument":{"uri":"#{uri}","languageId":"crystal","version":1,"text":"put \\"hello\\"; Thing.new"}}})
end
