## v0.8.1

- Fix compilation error "undefined constant Crystal::Codegen::Target"
- Update to crystal 0.30.1

## v0.8.0

### Scry

- Fix formatting untitled file [#65](https://github.com/crystal-lang-tools/scry/pull/65)
- Analyze files with implicit requires [#80](https://github.com/crystal-lang-tools/scry/pull/80)
- Change default log level to info [#93](https://github.com/crystal-lang-tools/scry/pull/93)
- Add workspace symbols [#106](https://github.com/crystal-lang-tools/scry/pull/106)
- Add symbol end_position using end_location [#114](https://github.com/crystal-lang-tools/scry/pull/114)
- Do not use File.each_line iterator to ensure Files are closed [#116](https://github.com/crystal-lang-tools/scry/pull/116)
- Add hover [#107](https://github.com/crystal-lang-tools/scry/pull/107)
- Log to client [#115](https://github.com/crystal-lang-tools/scry/pull/115)
- Add class and module name completion [#100](https://github.com/crystal-lang-tools/scry/pull/100)
- Log response on exception [#123](https://github.com/crystal-lang-tools/scry/pull/123)
- Various other bug fixes/code refactors

### Protocol

- Handle exit and shutdown request [#76](https://github.com/crystal-lang-tools/scry/pull/76)
- Fixes InitializeParams to follow LSP specification [#82](https://github.com/crystal-lang-tools/scry/pull/82)
- Add Protocol namespace [#134](https://github.com/crystal-lang-tools/scry/pull/134)

### CI

- On ci check that code is formatted [#57](https://github.com/crystal-lang-tools/scry/pull/57)
- Update to use latest version of Crystal (v0.27.0)
