require "json"
require "./ide_customizations"

module Scry
  struct Settings
    JSON.mapping({
      crystal_ide: { type: IDECustomizations, key: "crystal-lang" }
    }, true)
  end
end
