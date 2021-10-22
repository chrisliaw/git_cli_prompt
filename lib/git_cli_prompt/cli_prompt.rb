
require 'tty/prompt'

module GitCliPrompt
  module CliPrompt

    def method_missing(mtd, *args, &block)
      if pmt.respond_to?(mtd)
        pmt.send(mtd, *args, &block)
      else
        super
      end
    end

    private
    def pmt
      if @pmt.nil?
        @pmt = TTY::Prompt.new
      end
      @pmt
    end

  end
end
