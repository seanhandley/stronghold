module Net
  class HTTP < Protocol
    alias default_timeout_initializer initialize
    def initialize(address, port = nil)
      default_timeout_initializer(address, port)
      #@keep_alive_timeout = 2
      @open_timeout = 2
      @read_timeout = 5
      @continue_timeout = 5
      @ssl_timeout = 2
    end
  end
end