require "./db"
require "../log"

module Scry::Completion
  TYPE_REGEXP      = /[A-Z][a-zA-Z_:]+/
  NEW_REGEXP       = /(?<type>#{TYPE_REGEXP})(?:\(.+\))?\.new/
  FUNC_CALL_REGEXP = /(?<class>#{TYPE_REGEXP})\.(?<method>\w+)[\(\s]/

  class Context
    getter context, content

    @db : Db?
    @context : String
    @content : String
    @splitted : Array(String)

    def initialize(@context : String, @db = nil)
      content = ""
      (@context.size - 1).downto 0 do |i|
        break unless @context[i].to_s.match /[@A-Za-z0-9_\.:]/
        content += @context[i]
      end
      @content = content.reverse
      @splitted = @content.split '.'
    end

    def get_type
      if raw_type = get_raw_type
        raw_type
      elsif m = @context.match /#{@splitted.first} = #{NEW_REGEXP}/
        m["type"]
      elsif m = @context.match /#{@splitted.first} : (?<type>#{TYPE_REGEXP})/
        m["type"]
      elsif (m = @context.match /#{@splitted.first} = #{FUNC_CALL_REGEXP}/) && (db = @db)
        pattern = "#{m["class"]}.#{m["method"]}"
        res = db.match pattern
        if res.size == 1 && (entry = res.first) &&
           (m = entry.signature.match /:\s?(#{TYPE_REGEXP})(?:\(.+\))?\s*$/)
          return m[1]
        else
          Log.logger.debug "Fail to get the return type of function call : #{m}"
        end
      elsif match = @context.match /def #{@splitted.first}\(.*\) : (?<type>#{TYPE_REGEXP})/
        match["type"]
      else
        Log.logger.debug "Can't find the type of \"#{@splitted.first}\""
        nil
      end
    end

    def get_raw_type
      if @context.match /#{@splitted.first} = (true|false)\s/
        "Bool"
      elsif m = @context.match /#{@splitted.first} = [-+]?[0-9]+(_([iu])(8|16|32|64))?/
        if m[1]?
          "#{(m[2] == "i" ? "Int" : "UInt")}#{m[3]}"
        else
          "Int32"
        end
      end
    end

    def internal_match
      splitted = @content.split "::"

      if splitted.size == 1
        if scan = @context.scan(/ (#{@content}\w+)/)
          res = Array(DbEntry).new
          scan.each do |m|
            res << DbEntry.new m[1], "", EntryType::NameSpace
          end
          res
        else
          Array(DbEntry).new
        end
      else
        Array(DbEntry).new
      end
    end

    def is_namespace
      @context.ends_with? "::"
    end

    def is_class
      @splitted.first.match /^[A-Z]/
    end

    def is_dotted
      @splitted.size != 1
    end

    def class_method_pattern(type = @splitted.first)
      "#{type}.#{@splitted[1]?}"
    end

    def instance_method_pattern(type = @splitted.first)
      "#{type}##{@splitted[1]?}"
    end

    def namespace_pattern
      @content[0...-2]
    end

    def content_pattern
      @content
    end
  end
end
