# frozen_string_literal: true

#require 'tlogger'
require 'teLogger'
require 'toolrack'

include TeLogger

require 'gvcs'
require 'git_cli'

require_relative "git_cli_prompt/version"
require_relative "git_cli_prompt/cli_prompt"
require_relative "git_cli_prompt/logger"

require_relative "commit"
require_relative "tag"
require_relative "push"

module GitCliPrompt
  class Error < StandardError; end

  class UserSelectNone < StandardError; end
  class UserChangedMind < StandardError; end
  class UserAborted < StandardError; end
  # Your code goes here...
end
