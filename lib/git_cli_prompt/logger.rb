
require 'tlogger'

module GitCliPrompt
  module Logger
    
    def logger
      if @logger.nil?
        @logger = Tlogger.new
      end
      @logger
    end

  end
end
