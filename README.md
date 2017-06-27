# Scry for vscode-crystal-lang

[![Join the chat at https://gitter.im/crystal-scry/Lobby](https://badges.gitter.im/crystal-scry/Lobby.svg)](https://gitter.im/crystal-scry/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build Status](https://travis-ci.org/kofno/scry.svg?branch=master)](https://travis-ci.org/kofno/scry)

Scry is a code analysis server for [Crystal](http://crystal-lang.org).
It is an implementation of a [common language protocol](https://code.visualstudio.com/blogs/2016/06/27/common-language-protocol).
It is being built as a server for VSCode, but is compatible with any
client that implements this [protocol](https://github.com/Microsoft/language-server-protocol).

The server is implemented in Crystal.

## Installation

Scry will be distrubted as part of the [Crystal Language](https://github.com/faustinoaq/vscode-crystal-lang/tree/support-scry) extension
for VSCode.

## Development && Roadmap

Ongoing, in my free time.

The goal is too implement all of the currently supported Language Server Features.

 * Document Highlights: highlights all 'equal' symbols in a text document.
 * Hover: provides hover information for a symbol selected in a text document.
 * Signature Help: provides signature help for a symbol selected in a text document.
 * Goto Definition: provides go to definition support for a symbol selected in a text document.
 * Find References: finds all project-wide references for a symbol selected in a text document.
 * List Document Symbols: lists all symbols defined in a text document.
 * List Workspace Symbols: lists all project-wide symbols.
 * Code Actions: compute commands for a given text document and range.
 * CodeLens: compute CodeLens statistics for a given text document. (OK, maybe not this one)
 * Document Formatting: this includes formatting of whole documents, document ranges and formatting on type.
 * Rename: project-wide rename of a symbol.

## Contributing

1. Fork it ( https://github.com/kofno/scry/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [kofno](https://github.com/kofno) Ryan L. Bell - creator, maintainer
- [faustinoaq](https://github.com/faustinoaq) Faustino Aguilar - contributor
