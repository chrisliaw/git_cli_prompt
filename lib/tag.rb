

module GitCliPrompt
  module Tag
    include TR::CondUtils
    include CliPrompt
    include TR::VerUtils

    class TagError < StandardError; end

    def tag(root, version, &block)
    
      raise TagError, "Workspace root cannot be empty" if is_empty?(root)
      raise TagError, "Version name cannot be empty" if is_empty?(version)

      ws = Gvcs::Workspace.new(root)

      if ws.is_workspace?
        vers = possible_versions(currentVersion)

        vers << "Custom"
        vers << [
          "Not feeling to tag now" \
          ,"Maybe not now..." \
          ,"Nah, forget it..." \
        ].sample

        sel = pmt.select("Please select one of the options below:") do |menu|
          vers.each do |v|
            menu.choice v
          end
        end

        case sel
        when "Custom"
          sel = pmt.ask("Please provide custom version no:", required: true) 
        when vers[-1]
          raise UserChangedMind
        end

        defTagMsg = block.call(:default_tag_message) if block
        if is_empty?(defTagMsg)
          defTagMsg = "Automated tagging of source code of release version #{sel}" 
        end

        msg = pmt.ask("Message for this tag : ", default: defTagMsg)

        ws.create_tag(sel, msg)

      else
        raise TagError, "Given path '#{root}' is not a workspace"
      end


    end

  end
end
