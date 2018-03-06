# HACK: to avoid requiring the whole compiler
module Crystal
  struct CrystalPath
    class Error
      def to_s_with_source(source, io)
      end
    end
  end

  class Exception
    def to_json_single(json)
      json.object do
        json.field "message", @message
      end
    end
  end
end
