module Scry::ToolHelper
  def get_scope(root_uri)
    main_file = "#{root_uri}/.scry.cr"
    if File.exists?(main_file)
      [main_file]
    elsif Dir.exists?("#{root_uri}/src")
      Dir.glob("#{root_uri}/src/*.cr")
    else
      Dir.glob("#{root_uri}/**/*.cr")
    end
  end
end
