
module GitCliPrompt
  module Push
    include TR::CondUtils
    include CliPrompt

    class PushError < StandardError; end
    
    def push(root, &block)
    
      raise PushError, "Root is empty" if is_empty?(root)

      begin

        ws = Gvcs::Workspace.new(root)

        raise PushError, "#{root} is not a workspace" if not ws.is_workspace?

        conf = ws.remote_config
        if is_empty?(conf)
          res = pmt.yes?("  There is no remote repository configured for workspace at '#{File.expand_path(root)}'. Do you want to add one?")
          raise UserAborted if not res 
          name, url = prompt_new_remote

          ws.add_remote(name, url)

          conf = ws.remote_config
        end

        branch = block.call(:push_to_branch) if block
        branch = ws.current_branch if is_empty?(branch)

        if conf.keys.length == 1
          # direct push
          name = conf.keys.first
          url = conf.values.first["push"]
          if confirm_push(name, url)
            ws.push_changes_with_tags(name, branch)
            block.call(:push_info, { name: name }) if block
          else
            raise UserAborted
          end
        else
          raise UserChangedMind
        end

      rescue TTY::Reader::InputInterrupt
      end
    end

    def confirm_push(name, url)
      
      pmt.yes?("  Confirm push to repository '#{name}' [#{url}]?")

    end


    def prompt_new_remote
      
      name = pmt.ask("  Please provide a name of this remote config :", required: true)
      url = pmt.ask("  Please provide the URL:", required: true)

      if confirm_input(name, url)
        [name, url]
      else
        raise UserChangedMind
      end

    end

    def confirm_input(name, url)
     
      cont = []
      cont << ""
      cont << "  Name : #{name}"
      cont << "  URL  : #{url}"
      cont << ""

      pmt.yes?("  You've provided the following info. Proceed?\n#{cont.join("\r\n")}")

    end

  end
end
