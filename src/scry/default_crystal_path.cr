module Scry
  def self.default_crystal_path
    Crystal::CrystalPath.default_path.split(":").map do |path|
      if File.exists?(File.expand_path("prelude.cr", path))
        return path
      end
    end
    return ""
  end
end
