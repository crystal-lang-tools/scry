require "json"

module Scry::Protocol
  struct VoidParams
    def initialize(pull : JSON::PullParser)
      pull.read_begin_object
      pull.read_end_object
    end

    def to_json(json : ::JSON::Builder)
      json.object { nil }
    end
  end
end
