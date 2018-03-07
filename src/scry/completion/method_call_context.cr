module Scry::Completion
  class MethodCallContext < Context
    TYPE_REGEXP          = /[A-Z][a-zA-Z_:0-9]*/
    REVERSED_TYPE_REGEXP = /[a-zA-Z_:0-9]*[A-Z]/
    NEW_REGEXP           = /(?<type>#{TYPE_REGEXP})(?:\(.+\))?\.new/
    CLASS_REGEXP         = /(?<class_name>#{TYPE_REGEXP})/

    def initialize(@text : String, @target : String, @method : String, @method_db : MethodDB)
    end

    def find
      t = get_type
      res = t ? @method_db.matches([t], @method) : [] of MethodDBEntry
      to_completion_items res
    end

    def get_type
      if @target =~ CLASS_REGEXP
        "#{$~["class_name"]}.class"
      elsif @text.reverse =~ Regex.union(assignment_regex, declaration_regex)
        if $~["object"]?
          case $~["object"].reverse
          when /true|false/
            "Bool"
          when /[-+]?[0-9]+(_([iu])(8|16|32|64))?/
            if $~[1]?
              "#{($~[2] == "i" ? "Int" : "UInt")}#{$~[3]}"
            else
              "Int32"
            end
          when NEW_REGEXP
            $~["type"]
          end
        elsif $~["type"]?
          $~["type"].reverse
        end
      end
    end

    def assignment_regex
      /(?<object>.*)\s*=\s*#{@target.reverse}/
    end

    def declaration_regex
      if @target.starts_with?("@")
        Regex.union(/(?<type>#{REVERSED_TYPE_REGEXP})\s*:\s*#{@target[1..-1].reverse}\s*#{"property".reverse}/,
          /(?<type>#{REVERSED_TYPE_REGEXP})\s*:\s*#{@target[1..-1].reverse}\s*#{"setter".reverse}/,
          /(?<type>#{REVERSED_TYPE_REGEXP})\s*:\s*#{@target[1..-1].reverse}\s*#{"getter".reverse}/
        )
      else
        /(?<type>#{REVERSED_TYPE_REGEXP})\s*:\s*#{@target.reverse}/
      end
    end

    def to_completion_items(results : Array(MethodDBEntry))
      results.map do |res|
        CompletionItem.new(res.name,
                           CompletionItemKind::Method,
                           "#{res.name}#{res.signature}",
                           MethodCallContextData.new(res.file_path, res.location))
      end
    end
  end
end
