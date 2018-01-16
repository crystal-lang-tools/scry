require "json"
require "../log"

module Scry::Completion
  enum EntryType
    NameSpace
    Function

    def to_json(builder)
      builder.string(to_s)
    end
  end

  struct DbEntry
    JSON.mapping(
      name: String,
      file: String,
      location: String?,
      type: EntryType,
      signature: String
    )

    def initialize(@name : String, node : Crystal::Def, @file : String, @type = EntryType::Function)
      @signature = node.to_s.partition("\n")[0]
      @location = node.location.to_s if node.location
    end

    def initialize(@name, @file, @type, @signature = "", @location = nil)
    end

    def_equals_and_hash @name, @type
  end

  class Db
    @raw_storage = Set(DbEntry).new

    @path_stack = Array(String).new

    def add_path(@load_path : String)
    end

    def with_context(ctx : String) : Array(DbEntry)
      context = Context.new ctx, self
      print(context)
      res = Array(DbEntry).new
      if context.is_namespace
        res = match context.namespace_pattern, EntryType::NameSpace
      elsif context.is_class && !context.is_dotted
        res = match context.content_pattern, EntryType::NameSpace
        if res.empty?
          res = context.internal_match
        end
      elsif context.is_class
        res = match context.class_method_pattern
      elsif (var_type = context.get_type) && context.is_dotted
        res = match context.instance_method_pattern var_type
      elsif var_type # && !context.is_dotted
        tmp = match context.instance_method_pattern(var_type)
        # do not return methods that can only be called with a dot
        res = tmp.select { |e| e.name.match /#[^\w]/ }
      else
        Log.logger.debug "Can't extract anything : #{ctx[-10..-1]}"
      end

      if res.empty?
        Log.logger.debug "No match found for #{context.content_pattern}"
      end

      res
    end

    def match(pattern : String, etype = EntryType::Function) : Array(DbEntry)
      @raw_storage.select do |entry|
        entry.name.includes?(pattern) && entry.type == etype
      end
    end

    def starts_with?(pattern : String) : Array(DbEntry)
      res = Array(DbEntry).new
      @raw_storage.each do |entry|
        if entry.name.starts_with?(pattern)
          res << entry
        end
      end
      res.uniq
    end

    def push_module(name : String, file = "")
      @path_stack << name
      @raw_storage << DbEntry.new @path_stack.join("::"), file, EntryType::NameSpace
    end

    def push_class(node : Crystal::ClassDef, file = "")
      @path_stack << node.name.to_s.split("::").last
      @raw_storage << DbEntry.new @path_stack.join("::"), file, EntryType::NameSpace
    end

    def push_def(func : Crystal::Def, file : String)
      func_sep = (func.receiver ? "." : "#")
      full = @path_stack.join("::") + "#{func_sep}#{func.name}(#{func.args.join(',')})"
      full += ": #{func.return_type}" if func.return_type

      @raw_storage << DbEntry.new full, func, file
    end

    def pop_module
      @path_stack.pop?
    end

    def pop_class
      @path_stack.pop?
    end
  end
end
