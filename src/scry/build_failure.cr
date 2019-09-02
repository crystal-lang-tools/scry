module Scry
  # Failure JSON output by Crystal compiler
  struct BuildFailure
    JSON.mapping({
      file:    String,
      line:    Int32?,
      column:  Int32,
      size:    Int32?,
      message: String,
      source:  String,
    }, true)

    @source = "Scry"
  end
end
