
require 'git_cli_prompt'

class Commit
  include GitCliPrompt::Commit
end

RSpec.describe GitCliPrompt::Commit do

  it 'prompt user during commit workflow' do
  
    c = Commit.new
    c.commit "../test"

  end


end
