module Scry::ToolHelper
  def get_scope(root_uri)
    main_file = File.join(root_uri, ".scry.cr")
    if File.exists?(main_file)
      [main_file]
    elsif Dir.exists?(File.join(root_uri, "src"))
      Dir.glob(File.join(root_uri, "src", "*.cr"))
    else
      Dir.glob(File.join(root_uri, "**", "*.cr"))
    end
  end
end
