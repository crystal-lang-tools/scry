require "./lsp/protocol"
require "./scry/build_failure"

alias Scry::Protocol = LSP::Protocol
alias LSP::Protocol::BuildFailure = Scry::BuildFailure

module LSP; end
