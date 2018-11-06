## v0.8.0

### Scry

- Fix formatting untitled file (#65)
- Analyze files with implicit requires (#80)
- Change default log level to info (#93)
- Add workspace symbols (#106)
- Add symbol end_position using end_location (#114)
- Do not use File.each_line iterator to ensure Files are closed (#116)
- Add hover (#107)
- Log to client (#115)
- Add class and module name completion (#100)
- Log response on exception (#123)
- Various other bug fixes/code refactors

### Protocol

- Handle exit and shutdown request (#76)
- Fixes InitializeParams to follow LSP specification (#82)
- Add Protocol namespace (#134)

### CI

- On ci check that code is formatted (#57)
- Update to use latest version of Crystal (v0.27.0)