module Scry
  struct Settings
    JSON.mapping({
      crystal_ide: { type: IDECustomizations, key: "crystal-ide" }
    }, true)
  end
end
