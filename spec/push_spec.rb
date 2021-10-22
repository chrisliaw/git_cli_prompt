
require 'git_cli_prompt'

class Push
  include GitCliPrompt::Push
end

RSpec.describe GitCliPrompt::Push do

  it 'pushes source code to remote repository' do
    
    pu = Push.new
    pu.push("../test")

  end

end
