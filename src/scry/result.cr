module Scry

  class Result

    private getter request : Scry::NotificationMessage | Scry::RequestMessage | Scry::RequestMessageNoParams

    def initialize(@request)
    end

  end

end
