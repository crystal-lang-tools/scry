# Scry

[![Join the chat at https://gitter.im/crystal-scry/Lobby](https://badges.gitter.im/crystal-scry/Lobby.svg)](https://gitter.im/crystal-scry/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build Status](https://travis-ci.org/crystal-lang-tools/scry.svg?branch=master)](https://travis-ci.org/crystal-lang-tools/scry)

![Scry logo](https://i.imgur.com/ticTfT8.png)

Scry is a code analysis server for [Crystal](http://crystal-lang.org).
It is an implementation of a [common language protocol](https://code.visualstudio.com/blogs/2016/06/27/common-language-protocol).
It is being built as a server for VSCode, but is compatible with any
client that implements this [protocol](https://microsoft.github.io/language-server-protocol).

The server is implemented in Crystal.

## Installation

Scry will be distrubuted as part of editors extensions, see:

- [ide-crystal](https://github.com/crystal-lang-tools/atom-crystal) for Atom
- [vscode-crystal-ide](https://github.com/kofno/crystal-ide)
- [vscode-crystal-lang](https://github.com/faustinoaq/vscode-crystal-lang)

## Known issues

- Some diagnostics don't disappear after fixing the code.

## Development && Roadmap

> **Note:** crystal and LLVM are required in order to compile scry.

Ongoing, in [our](https://github.com/kofno/scry#contributors) free time.

The goal is too implement all of the currently supported Language Server Features.

- [Diagnostics](https://microsoft.github.io/language-server-protocol/specification#textDocument_publishDiagnostics) **(WIP)**: provides problem detection for text document.
- [Document Formatting](https://microsoft.github.io/language-server-protocol/specification#textDocument_formatting) **(WIP)**: this includes formatting of whole documents, document ranges and formatting on type.
- [Goto Definition](https://microsoft.github.io/language-server-protocol/specification#textDocument_definition): **(WIP)** provides go to definition support for a symbol selected in a text document.
- [Document Highlights](https://microsoft.github.io/language-server-protocol/specification#textDocument_documentHighlight): highlights all 'equal' symbols in a text document.
- [Hover](https://microsoft.github.io/language-server-protocol/specification#textDocument_hover): provides hover information for a symbol selected in a text document.
- [Signature Help](https://microsoft.github.io/language-server-protocol/specification#textDocument_signatureHelp): provides signature help for a symbol selected in a text document.
- [Find References](https://microsoft.github.io/language-server-protocol/specification#textDocument_references): finds all project-wide references for a symbol selected in a text document.
- [List Document Symbols](https://microsoft.github.io/language-server-protocol/specification#textDocument_documentSymbol): **(WIP)** lists all symbols defined in a text document.
- [List Workspace Symbols](https://microsoft.github.io/language-server-protocol/specification#workspace_symbol): **(WIP)** lists all project-wide symbols.
- [Code Actions:](https://microsoft.github.io/language-server-protocol/specification#textDocument_codeAction) compute commands for a given text document and range.
- [CodeLens](https://microsoft.github.io/language-server-protocol/specification#textDocument_codeLens): compute CodeLens statistics for a given text document. (OK, maybe not this one)
- [rename](https://microsoft.github.io/language-server-protocol/specification#textDocument_rename): project-wide rename of a symbol.

## Contributing

1. Fork it <https://github.com/crystal-lang-tools/scry/fork>
2. Create your feature branch `git checkout -b my-new-feature`
3. Commit your changes `git commit -am 'Add some feature'`
4. Push to the branch `git push origin my-new-feature`
5. Create a new Pull Request

## Contributors

- [@kofno](https://github.com/kofno) Ryan L. Bell - creator, maintainer
- [@keplersj](https://github.com/keplersj) Kepler Sticka-Jones - contributor
- [@faustinoaq](https://github.com/faustinoaq) Faustino Aguilar - contributor
