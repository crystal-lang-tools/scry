# Scry

Scry is a code analysis server for [Crystal](http://crystal-lang.org).
It is an implementation of a [common language protocol](https://code.visualstudio.com/blogs/2016/06/27/common-language-protocol).
It is being built as a server for VSCode, but is compatible with any
client that implements this [protocol](https://github.com/Microsoft/language-server-protocol).

The server is implemented in Crystal.

## Installation

The server will be distrubted as part of the [Crystal IDE](https://github.com/kofno/crystal-ide) extension
for VSCode.

TODO: Binary distrubtions

TODO: Distribute as a shard?

## Usage

Install on your path and then run Scry at the command line.

    $> scry

## Development

Close the repo and build using `crystal build`. Please observe the implicit code conventions.

Ask if you have questions.

## Contributing

1. Fork it ( https://github.com/kofno/scry/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [kofno](https://github.com/kofno) Ryan L. Bell - creator, maintainer
