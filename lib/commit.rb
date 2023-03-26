
require 'gvcs'
require 'git_cli'

require_relative 'git_cli_prompt/logger'

module GitCliPrompt
  module Commit
    include TR::CondUtils
    include CliPrompt
    include GitCliPrompt::Logger

    class CommitError < StandardError; end

    def commit(root,&block)
     
      #logger.debug "Commit operation root : #{root}"
      ws = Gvcs::Workspace.new(root)
      raise CommitError, "Given path '#{File.expand_path(root)}' is not a VCS workspace" if not ws.is_workspace?

      begin

        modDir, modFiles = ws.modified_files
        newDir, newFiles = ws.new_files
        delDir, delFiles = ws.deleted_files
        stDir, stFiles = ws.staged_files

        pending = false
        pending = true if not_empty?(modDir) or not_empty?(modFiles) or not_empty?(newDir) or not_empty?(newFiles) or not_empty?(delDir) or not_empty?(delFiles)

        staged = false
        staged = true if not_empty?(stDir) or not_empty?(stFiles)

        if not_empty?(stDir) or not_empty?(stFiles)
          say "  Item(s) already staged for commit: \n"
          stDir.each do |md|
            say "    #{md.path}"
          end
          stFiles.each do |md|
            say "    #{md.path}"
          end
        end

        if pending

          say "\n\n  Items could be add to version control:\n"
          cnt = 1
          [modDir, modFiles, newDir, newFiles, delDir, delFiles].each do |cont|
            cont.each do |md|
              say "  #{'%2s' % cnt}. #{md.to_s}\n"
              cnt += 1
            end
          end

        end

        puts

        if not pending and not staged
          pmt.say("\n  Workspace is clean. No changes or unstage files or directory is found.\n", color: :green) 
          "Workspace is clean. No changes or unstage files or directory is found"

        else

          ops = pmt.select("  Please select desired operation:") do |menu|
            menu.default 1

            menu.choice "  Add", :add if pending
            if not_empty?(stDir) or not_empty?(stFiles)
              menu.choice "  Remove file from staged", :remove_staged 
              menu.choice "  Commit staged", :commit
            end
            menu.choice "  Ignore changes", :ignore
            menu.choice "  Quit", :quit
          end

          case ops
          when :add
            choices = []
            choices += mark_modified_choice(modDir)
            choices += mark_modified_choice(modFiles)
            choices += mark_new_choice(newDir)
            choices += mark_new_choice(newFiles)
            choices += mark_del_choice(delDir)
            choices += mark_del_choice(delFiles)

            prompt_add_selection(ws, choices, &block)
            commit_staged(ws, &block)

          when :ignore
            pmt.ok "\n  Changes are ignored for this release", color: :yellow

          when :quit
            raise UserChangedMind

          when :remove_staged

            choices = []
            choices += stDir.map { |v| [v.path,v] }
            choices += stFiles.map { |v| [v.path,v] }

            sel = prompt_remove_staging(choices)
            ws.remove_from_staging(sel)

          when :commit

            commit_staged(ws, &block)

          end
        end


      rescue TTY::Reader::InputInterrupt => ex
        ok "\n\n  Aborted"

        if block
          th = block.call(:raise_to_parent)
          raise ex if is_bool?(th)
        end

      #rescue UserChangedMind
      #  ok "\n  Noted. Please retry the process again\n"

      #rescue UserSelectNone
      #  ok "\n  Nothing is selected. Process halted\n"

      #rescue Exception => ex
      #  error(ex.message)
      #  logger.error ex.message
      #  logger.error ex.backtrace.join('\n')

      end
    end

    def prompt_remove_staging(choices)
      
      sel = pmt.select("  Please select which item(s) to remove from staging:") do |menu|
        
        choices.each do |c|
          menu.choice c[0], c[1]
        end

      end

      raise UserSelectNone, "  No selection of staged item(s) were made" if is_empty?(sel)
      if confirm_selection(sel)
        sel
      else
        raise UserChangedMind, "  User aborted"
      end

    end

    def prompt_add_selection(ws, choices, &block)
      
      sel = multi_select("  Please select which items to add to this commit session:") do |menu|
        choices.each do |c|
          menu.choice c[0], c[1]
        end
      end

      raise UserSelectNone, "  No selection of unversioned item(s) was made" if is_empty?(sel)
      if confirm_selection(sel)
        psel = vcs_items_to_path_array(sel)
        ws.add_to_staging(psel)
      else
        raise UserChangedMind, "  User aborted"
      end

    end

    def confirm_selection(sel)
      
      sel = [sel] if not sel.is_a?(Array)
      cs = []
      cnt = 1
      sel.each do |s|
        cs << "#{"%2s" % cnt.to_s}. #{s}"
        cnt += 1
      end

      yes?("  You've selected the following item(s). Proceed?\n#{cs.join("\n")}\n")

    end

    def prompt_commit_message(&block)

      if block
        defMsg = block.call(:default_commit_message)
      end

      msg = pmt.ask("\n  Commit Message : ", required: true) do |m|
        m.default = defMsg if not_empty?(defMsg)
      end

      msg
    end

    def commit_staged(ws, &block)
      msg = prompt_commit_message(&block)
      output = ws.commit(msg)
      block.call(:changes_commited, msg, output) if block
      output
    end

    private
    def mark_new_choice(arr)
      res = []
      arr.each do |a| 
        res << [a.to_s,a]
      end
      res
    end

    def mark_modified_choice(arr)
      res = []
      arr.each do |a| 
        res << [a.to_s,a]
      end
      res
    end

    def mark_del_choice(arr)
      res = []
      arr.each do |a| 
        res << [a.to_s,a]
      end
      res
    end

    def vcs_items_to_path_array(array)
      array.map do |v|
        v.path
      end
    end


  end
end
