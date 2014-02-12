require 'optparse'
require 'vagrant-node/server'
require 'io/console'
require 'vagrant-node/dbmanager'

module Vagrant
  module Node
	class NodeServerPasswd < Vagrant.plugin(2, :command)
		def execute
	     options = {}

          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant nodeserver passwd"
          end
          
          # argv = parse_options(opts)
          # raise Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length > 1
          
          
          
          # if (argv.length==0)
  
  
            
            db = DB::DBManager.new(@env.data_dir)            
            
            #Checking if user knows the old password
            if (db.node_password_set? && !db.node_default_password_set?)              
              print "Insert current password: "
              old_password=STDIN.noecho(&:gets).chomp
              print "\n"
              if !db.node_check_password?(old_password)
                @env.ui.error("Password failed!")
                return 0
              end            
            end
            
            pass_m = "Insert your new password for this Node: "
            confirm_m = "Please Insert again the new password: "
            
   
            if STDIN.respond_to?(:noecho)
              print pass_m
              password=STDIN.noecho(&:gets).chomp
              print "\n#{confirm_m}"
              confirm=STDIN.noecho(&:gets).chomp
              print "\n"
            else
              #FIXME Don't show password 
              password = @env.ui.ask(pass_m)
              confirm = @env.ui.ask(confirm_m)
            end
            
            if (password==confirm)              
              db.node_password_set(password)
              @env.ui.success("Password changed!")
            else
              @env.ui.error("Passwords does not match!")
            end
  
  
  
            
          # else
            # puts "INTRODUCIDA EN TERMINAL"
          # end           
          
          
          		         		
          0
        end
        
	end
  end
end
