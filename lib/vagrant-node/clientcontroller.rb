
require 'vagrant'
require 'vagrant-node/actions/snapshot'
require 'vagrant-node/dbmanager'
require 'vagrant-node/pwmanager'
require 'vagrant-node/exceptions.rb'
require 'vagrant-node/configmanager'


module Vagrant
	module Node
	  
	    
	    
		class ClientController
			
			
			def self.execute_queued			
			  ensure_environment
			  #Generating a random identifier for process
			  rpid=rand(1000000)
			  
			  pid = fork do
			    begin
			     @db.create_queued_process(rpid)			     
			     res = yield			     
			     @db.set_queued_process_result(rpid,res.to_json)		     
			     
			    rescue Exception => e
			      @db.set_queued_process_error(rpid,e)			      
			    end
			  end
			  rpid
			end
			
			def self.send_challenge			  
			  challenge = SecureRandom.urlsafe_base64(nil, false)
			  cookie = SecureRandom.urlsafe_base64(nil, false)			  
			  
			  
			  {:cookie => cookie, :challenge => challenge}
			end
			
			def self.authorized?(token,challenge)
			 ensure_environment			 
			 
			 @pw.authorized?(token,challenge)			 
			end
			
			################################################################
			#######################  BOX LIST METHOD #######################
			################################################################			
			def self.listboxes
			  
			
  				ensure_environment
  				
  				boxes = @env.boxes.all.sort				
  				
  				fboxes = Array.new				
  				boxes.each do |name, provider|					
  					fboxes << {"name" => name,"provider" => provider}
  				end
  				
  				
  				fboxes		
			
				
			end			
			
			################################################################
			#######################  BOX DELETE METHOD #####################
			################################################################			
			def self.box_delete(box,provider)
			
				ensure_environment
				
				boxes = []			

			  box = @env.boxes.find(box,provider.to_sym)
			  
			  if (box)			  	
			  	boxes << box.name			  
			  	box.destroy!			  				  	
			  end 
								
				boxes
				
			end
			
			################################################################
			########################  BOX ADD METHOD #######################
			################################################################			
			def self.box_add(box,url,user="guest",pass="--no-pass")
				command_block = Proc.new {
                  				#ensure_environment
                  				
                  				boxes = []			
                  
                  				#TODO
                  				
                  				# Get the provider if one was set
                  				provider = nil
                  #				provider = options[:provider].to_sym if options[:provider]
                  
                  				begin
                  					
                  					#uri = "\\\\155.54.190.227\\boxtmp\\boxes\\debian_squeeze_32.box"
                  #					
                  #					if uri=~ /^\\\\(.*?)\\(.*?)\\(.*?)$/						
                  #						puts "EL HOST ES #{$1}"
                  #						puts "EL Share ES #{$2}"
                  #						puts "EL PATH ES #{$3}"
                  #						host = $1
                  #						share = $2
                  #						path = $3
                  #						
                  #						Getting and checking box file						
                  #						boxname=File.basename(path.gsub('\\',File::SEPARATOR))
                  #						
                  #            raise 'Box file format not supported' if File.extname(boxname)!=".box"
                  #
                  #						samba = nil
                  #						begin						
                  #						samba = Sambal::Client.new(  :host     =>  host,
                  #																				:share    =>  share,
                  #																				:user     =>  user,
                  #																				:password =>  pass)
                  #					
                  #						
                  #						
                  #						Get the tmp file name					
                  #						temp_path = @env.tmp_path.join("box" + Time.now.to_i.to_s)
                  #				
                  #					
                  #						response = nil
                  #						
                  #						smbclient //155.54.190.227/boxtmp --no-pass -W WORKGROUP -U guest -p 445
                  #						smbclient //155.54.190.227/boxtmp -D boxes -c "get debian_squeeze_321.box" -N
                  #						
                  #						command="smbclient //#{host}/#{share} -D #{dirlocation} -c \"get #{boxname}\" -U #{user} --no-pass"
                  #						
                  #
                  #						FIXME encontrar si existe algún tipo de notificación por
                  #						interrupciónde la descarga
                  #						FIXME a little hack beacuse in version 0.1.2 of sambal there is 
                  #						a timeout that close the download after 10 seconds 
                  #						def samba.ask(cmd)							
                  #							@i.printf("#{cmd}\n")
                  #							response = @o.expect(/^smb:.*\\>/)[0]				
                  #						end
                  #						
                  #						response = samba.get(path, temp_path.to_s)
                  #						FIXME DELETE
                  #						pp response.inspect						
                  #						
                  #						raise response.message if !response.success?
                  #						
                  #						if response.success?								
                  #								File download succesfully
                  #								added_box = nil
                  #								begin									
                  #									provider=nil
                  #									force = true
                  #									added_box = @env.boxes.add(temp_path,box,nil,force)									
                  #									boxes << {:name=>box,:provider=>added_box.provider.to_s}
                  #								rescue Vagrant::Errors::BoxUpgradeRequired									
                  #									Upgrade the box
                  #									env.boxes.upgrade(box)
                  #			
                  #									Try adding it again
                  #									retry
                  #								rescue Exception => e									
                  #									boxes = nil
                  #								end
                  #													
                  #						end
                  #						
                  #						rescue Exception => e
                  #							puts "EXCEPCION de descarga" if response
                  #							puts "EXCEPCION de conexion" if !response
                  #							puts e.message
                  #							boxes=nil
                  #						end
                  #						
                  #						
                  #						Closing connection
                  #						samba.close if samba
                  #						
                  #						
                  #						Cleaning
                  #						if temp_path && File.exist?(temp_path)
                  #            	File.unlink(temp_path)
                  #          	end
                  # 
                  #          	          		 
                  #					else
                  
                            
                            
                              boxes <<{:name=>box}
                  #						FIXME Ver qué poner en los parámetros de la llamada
                  						provider=nil
                  						force = true # Always overwrite box if exists
                  						insecure = true #Don't validate SSL certs
                  						#Calling original box add action
                  						@env.action_runner.run(Vagrant::Action.action_box_add, {
                              :box_name     => box,
                              :box_provider => provider,
                              :box_url      => url,
                              :box_force    => force,
                              :box_download_insecure => insecure,
                            	})
                  
                  #					end
                  
                  
					     
					     

                                      
              boxes					     
					     
				rescue =>e
						puts e.message
				end

				}
        method("execute_queued").call(&command_block);
				
			end
			
			
			
			################################################################
			##################  VIRTUAL MACHINE UP METHOD ##################
			################################################################
			def self.vm_up(vmname)
			  command_block = Proc.new {
				#ensure_environment
					
				machine_names = []
	
				#begin
	        
					options = {}
					options[:parallel] = true
				
					#Launching machines
					@env.batch(options[:parallel]) do |batch|			
						get_vms(vmname).each do |machine|
							batch.action(machine, :up, options)							
							machine_names << {"vmname" => machine.name.to_s,
																"status" => "running"}												
						end
					end           
					
					
					machine_names
					}
					
					method("execute_queued").call(&command_block);
					
				# rescue Vagrant::Errors::BoxNotFound => e
				  # puts "BOX NOT FOUND"
				# rescue => e
				  # pp e
				  # puts e.message
				  # raise RestException.new(404,e.message)								 
				# end
				
			end
		
		 
			
			
			################################################################
      ################  VIRTUAL MACHINE ADD METHOD ###############
      ################################################################
    
      def self.vm_add(config,rename)
        ensure_environment    
        begin  
          path="/tmp/conf."+Time.now.to_i.to_s          
          f = File.new(path, "w")
          f.write(config)
          f.close          
                  
                   
          cm = ConfigManager.new(@env.root_path+"Vagrantfile")
          cmtmp = ConfigManager.new(path)
          
                 
          current_vms = @env.machine_names
          
          cmtmp.get_vm_names.each do |key|             
           
            if current_vms.include?(key)  
              raise RestException.new(406,"There is a remote VM with the same name: \"#{key}\"") if rename=="false"             
              cmtmp.rename_vm(key,"#{key}_1")            
            end    
          end
          
          cm.insert_vms_sexp(cmtmp.extract_vms_sexp)
            
       rescue => e   
         raise e 
       ensure
         File.delete(path)
       end      
        
        
      end
      
      			
			################################################################
      ################  VIRTUAL MACHINE DELETE METHOD ###############
      ################################################################
    
      def self.vm_delete(vmname,remove=false)
        ensure_environment
        
        cm = ConfigManager.new(@env.root_path+"Vagrantfile")         
        
        self.vm_confirmed_destroy(vmname) if remove!=false
        
        cm.delete_vm(vmname) 
        
        true        
        
      end
			
			 ################################################################
      ################  VIRTUAL MACHINE DESTROY METHOD ###############
      ################################################################
    
      def self.vm_confirmed_destroy(vmname)
        ensure_environment
        
        machine_names = []
  
        
        #begin        
        
          get_vms(vmname.to_sym).each do |machine|                       
            machine_names << machine.name
            machine.action(:destroy, :force_confirm_destroy => true)            
          end
                          
          machine_names
          
        #rescue => e          
#         return nil
        #end
        
      end
			
			################################################################
			#################  VIRTUAL MACHINE HALT METHOD #################
			################################################################
			def self.vm_halt(vmname,force)
			  command_block = Proc.new {
  				#ensure_environment				
  			
  				machine_names = []
  	
  				#begin				
  					
  					get_vms(vmname).each do |machine|						
  						machine.action(:halt, :force_halt => force)
  						machine_names << {"vmname" => machine.name.to_s,
  															"status" => machine.state.short_description}
  					end
  							
  					machine_names
					}
					
					method("execute_queued").call(&command_block);
				
				#rescue => e					
#					return nil
				#end
				
			end
			
			################################################################
			#################  VIRTUAL MACHINE STATUS METHOD ###############
			################################################################
			def self.vm_status(vmname=nil)
				ensure_environment				
				
				
					
				status = Array.new
									
				get_vms(vmname).each do |machine|
						
					status << {"name" => machine.name.to_s,
								"status" => machine.state.short_description,
								"provider" => machine.provider_name}
				end		
			
			
				status
							
				
				
			end
			
			################################################################
			##################  VIRTUAL MACHINE SUSPEND METHOD ##################
			################################################################
			def self.vm_suspend(vmname)
			  command_block = Proc.new {
				  #ensure_environment
			
				  machine_names = []
			
				
				
					
					#Suspendiing machines								
					get_vms(vmname).each do |machine|
						machine.action(:suspend)
						machine_names << {"vmname" => machine.name.to_s,
																"status" => machine.state.short_description}
					end           
					
				
				  machine_names
				  
				}
					
				method("execute_queued").call(&command_block);
				
			end
		
			################################################################
			##################  VIRTUAL MACHINE RESUME METHOD ##################
			################################################################
			def self.vm_resume(vmname)
			  command_block = Proc.new {
				#ensure_environment
			
				machine_names = []			
					#Launching machines
								
					get_vms(vmname).each do |machine|
						machine.action(:resume)
						machine_names << {"vmname" => machine.name.to_s,
															"status" => machine.state.short_description}					
					end
					           
					
				
					machine_names
				}
				
				method("execute_queued").call(&command_block);
				
				
			end
			
			################################################################
			############  VIRTUAL MACHINE SNAPSHOT LIST METHOD #############
			################################################################
			def self.vm_snapshots(vmname=nil)
				ensure_environment				
				
				#begin
				
					snapshots = {}
										
					get_vms(vmname).each do |machine|
						
						env = 
						{							
        			:machine        => machine,
        			:machine_action => SnapshotAction::LIST
						}
						
						
						res = @env.action_runner.run(SnapshotAction,env)
						
						snapshots[machine.name.to_sym]=res[:snapshots_list]
						
					end		
				
				  
					snapshots
							
				# rescue => e
					# puts e.message
# #					return nil				
				# end
				
			end
			
			################################################################
			############  VIRTUAL MACHINE SNAPSHOT TAKE METHOD #############
			################################################################
			def self.vm_snapshot_take(vmname,name,desc=" ")
			  command_block = Proc.new {
				#ensure_environment				
				
					
					raise RestException.new(404,"Virtual Machine not specified") if (vmname==nil ||vmname.empty?)
					
					
					machine = get_vms(vmname)
					raise RestException.new(404,"Virtual Machine not found") if (machine.empty?)
					
           env = 
           {              
              :machine        => machine.first,
              :machine_action => SnapshotAction::TAKE,
              :snapshot_name  => name,
              :snapshot_desc  => desc             
            }
              
            res = @env.action_runner.run(SnapshotAction,env)
              
            res[:last_snapshot]            
            
           		
					# get_vms(vmname).each do |machine|
					 # env = 
					 # {							
        			# :machine        => machine,
        			# :machine_action => SnapshotAction::TAKE,
        			# :snapshot_name 	=> name,
        			# :snapshot_desc  => desc        			
						# }
#  						
						# res = @env.action_runner.run(SnapshotAction,env)
# 						
						# return res[:last_snapshot]						
# 						
					# end
					
					
				}		
					
				method("execute_queued").call(&command_block);
				
			end
			
			################################################################
      ############  VIRTUAL MACHINE SNAPSHOT DELETE METHOD #############
      ################################################################
      def self.vm_snapshot_delete(vmname,snapshot_id)
        ensure_environment        
        
        #begin
          
          
          raise RestException.new(404,"Virtual Machine not specified") if (vmname==nil ||vmname.empty?)
          
           
               
          get_vms(vmname).each do |machine|
            env = 
            {             
              :machine        => machine,
              :machine_action => SnapshotAction::DELETE,
              :snapshot_id  => snapshot_id,               
            }
#             
#             
            res = @env.action_runner.run(SnapshotAction,env)
#             
            return res[:delete_snapshot]
#             
          end   
#           
        # rescue => e
          # puts e.message
# #         return nil        
        # end
        
      end
			
			
			
			################################################################
			############  VIRTUAL MACHINE SNAPSHOT RESTORE METHOD #############
			################################################################
			def self.vm_snapshot_restore(vmname,snapshot_id)
			  command_block = Proc.new {
				  #ensure_environment				
				
				  raise RestException.new(404,"Virtual Machine not specified") if (vmname==nil ||vmname.empty?)
				  
				  restore_results = {}
					
									
					get_vms(vmname).each do |machine|				  
					
					  
						prev_state=machine.state.id
						#First, ensure that the machine is in a proper state
						#to restore the snapshot (save, poweroff)
						machine.action(:suspend) if prev_state==:running
						
						#Now the machine is ready for restoration
						env = 
						{							
        			:machine        => machine,
        			:machine_action => SnapshotAction::RESTORE,
        			:snapshot_id 	=> snapshot_id        			   			
						}
						
						
						res = @env.action_runner.run(SnapshotAction,env)
						
						#Now restore the vm to the previous state if running
						machine.action(:up) if prev_state==:running
						
						restore_results[machine.name.to_sym]=res[:restore_result]						
					end		
					
					restore_results
					
					
		   }
			 method("execute_queued").call(&command_block);
				
			end
			
			
					
			################################################################
			##################  VIRTUAL MACHINE PROVISION METHOD ##################
			################################################################
			def self.vm_provision(vmname)
				#ensure_environment
			  command_block = Proc.new {
  				machine_names = []
  	
  	      # Por ahora no dejo que el vmname esté vacío para realizar la operación sobre todas las vm
  				raise RestException.new(404,"Virtual Machine not specified") if (vmname==nil ||vmname.empty?)
  				#begin
  				
  					#Provisioning								
  					get_vms(vmname).each do |machine|										
  						machine_names << machine.name	
  						machine.action(:provision)					
  					end
  					           
  					
  				
  					machine_names
				}
				
        method("execute_queued").call(&command_block);	
		
				
			end				
					
					
					
					
					
			################################################################
			###################  VIRTUAL MACHINE SSHCONFIG## ###############
			################################################################
			def self.vm_ssh_config(vmname)
				ensure_environment
				
				
				#Ensure vmname exists and it is not empty
				return nil if vmname.empty?
					
				
				#begin
					info = Array.new
					get_vms(vmname).each do |machine|												
						info << machine.ssh_info						
					end
					
					info[0]
					
				# rescue => e
					# puts e.message
#					return nil
				#end	
			
			end
		
			################################################################
			############  VIRTUAL MACHINE BACKUP TAKE METHOD #############
			################################################################
			def self.vm_snapshot_take_file(vmname)
				ensure_environment
				
				current_machine = nil
				t = Time.now.strftime "%Y-%m-%d %H:%M:%S"
				begin
				  
					machines=get_vms(vmname)
					
					return [404,"Virtual Machine not found"] if machines.empty?
										
					machines.each do |machine|						
						
						current_machine = machine.name.to_s						
						
						env = 
						{							
							:machine        => machine,
							:machine_action => SnapshotAction::BACKUP,
							:path						=> @env.data_dir
						}
						
						@db.add_backup_log_entry(t,current_machine,BACKUP_IN_PROGRESS)
		
						res = @env.action_runner.run(SnapshotAction,env)
						
						if res[:bak_filename] == SnapshotAction::ERROR
							@db.update_backup_log_entry(t,current_machine,BACKUP_ERROR)
							return [500,"Internal Error"] if res[:bak_filename] == SnapshotAction::ERROR
						else					
							@db.update_backup_log_entry(t,current_machine,BACKUP_SUCCESS)
							return [200,res[:bak_filename]]
						end
						
					end	
							
				rescue => e					
					@db.update_backup_log_entry(t,current_machine,BACKUP_ERROR)
					return [500,"Internal Error"]				
				end
				
			end
			
			################################################################
      ###################  NODE PASSWORD CHANGE    ###################
      ################################################################
			def self.password_change(new_password)
			  ensure_environment
			  
			  @db.node_password_set(new_password,true)
			  true
			end
			
			################################################################
			#################  BACKUP LOG METHOD ###############
			################################################################
			#FIXME No está controlado el que el parámetro sea nil
			def self.backup_log(vmname=nil)
				ensure_environment				
				
				#begin
				
					@db.get_backup_log_entries(vmname)
					
				# rescue => e
					# puts e.message									
				# end
				
			end
			
			
			################################################################
      ######################  CONFIG SHOW METHOD #####################
      ################################################################
			def self.config_show
			    ensure_environment			    
			    
			    file = @env.root_path+"Vagrantfile"
			end
			
			 ################################################################
      ######################  CONFIG UPLOAD METHOD #####################
      ################################################################
      def self.config_upload(cfile)
          ensure_environment
                              
          f = File.new(@env.root_path+"Vagrantfile", "w")
          f.write(cfile)
          f.close
          
          true
      end
      
      
      def self.operation_queued(id)          
          ensure_environment
          result = @db.get_queued_process_result(id)          
          
          raise RestException.new(404,"The operation ID: #{id} not found") if result.empty?
          
          result.first 
      end
      
      def self.operation_queued_last          
          ensure_environment
          
          @db.get_queued_last         
           
      end
      
      
			
			
			################################################################
			#######################  PRIVATE METHODS #######################
			################################################################
			private
			
			BACKUP_ERROR = "ERROR"
			BACKUP_SUCCESS = "OK"
			BACKUP_IN_PROGRESS = "IN PROGRESS"
			
			def self.ensure_environment
				#Due to the fact that the enviroment data can change
				#if we always use a stored value of env we won't be
				#able to notice those changes 				
#				if (!@env)
#					opts = {}					
#					@env = Vagrant::Environment.new(opts)					
#				end				
				
				opts = {}					
				@env = Vagrant::Environment.new(opts)
				@db = DB::DBManager.new(@env.data_dir) if (!@db)
				@pw = PwManager.new(@db) if (!@pw)
			end
			
			#FIXME REVISAR Y MEJORAR, LO HE HECHO DEPRISA PERO SE 
			#PUEDE OPTIMIZAR
			def self.get_vms(vmname)				
				machines = []
				provider=@env.default_provider
							
				if (vmname && !vmname.empty?)
						#If a machine was specified launch only that machine									
						name=vmname.to_sym
					if (@env.machine_names.index(name)!=nil)
						
						@env.active_machines.each do |active_name, active_provider|
												
							if name==active_name							
								provider=active_provider
								break							
							end
																				
						end
						machines << @env.machine(name,provider)
					end
	
				else
					#If no machine was specified launch all
					@env.machine_names.each do |machine_name|
							@env.active_machines.each do |active_name, active_provider|								
								if active_name==machine_name
									provider=active_provider
									break
								end
								
							end
							machines << @env.machine(machine_name,provider)
					end			
				end		
				
				machines
				
			end
			
		end
	end
end
