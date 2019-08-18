module Scry
  def self.default_crystal_path
    # Mimic the behavior of Crystal::CrystalPath.default_path
    # instead of requiring "compiler/crystal/crystal_path" which gives a lot
    # a require issues...
    default_path = ENV["CRYSTAL_PATH"]? || ENV["CRYSTAL_CONFIG_PATH"]? || ""

    default_path.split(':').each do |path|
      if File.exists?(File.expand_path("prelude.cr", path))
        return path
      end
    end

    ""
  end
end
