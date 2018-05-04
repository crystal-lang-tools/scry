module Scry
  def self.default_crystal_path
    Crystal::DEFAULT_PATH.split(":").map do |path|
      if File.exists?("#{path}/prelude.cr")
        return path
      end
    end
    return ""
  end
end
