require "log"
require "./client"

module Scry
  module Log
    class_property logger : ::Log = ::Log.for(self)
  end
end
