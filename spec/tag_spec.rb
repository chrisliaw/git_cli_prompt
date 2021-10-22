
require 'git_cli_prompt'

class Tag
  include GitCliPrompt::Tag
end

RSpec.describe GitCliPrompt::Tag do

  it 'tags source code of given version' do
   
    t = Tag.new
    t.tag('../test', "0.1.0")

  end

end
