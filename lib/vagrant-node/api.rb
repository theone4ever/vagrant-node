require 'rubygems'
require 'sinatra'
require 'json'
require 'rack'
require 'vagrant-node/clientcontroller'
require 'vagrant-node/apidesc'
require 'vagrant-node/exceptions'

require 'cgi'

require 'pp'
module Vagrant
	module Node
		module ServerAPI
			
			class API < Sinatra::Base
				include RestRoutes
				COOKIE_TOKEN_ID = "TOKEN"
				COOKIE_EXPIRATION_TIME = 5
				def initialize
				  super
				  @session_table=Hash.new
				end 
				#use Rack::Session::Pool, :expire_after => 2592000
				#enable :sessions
				# before do 
  					# content_type :json
				# end
				
				
				#UPLOAD A FILE
#				post '/' do
				#  tempfile = params['file'][:tempfile]
				#  filename = params['file'][:filename]
				#  File.copy(tempfile.path, "./files/#{filename}")
				#  redirect '/'
				#end		
				
				#before '^.*(^login).*' do
			before %r{^(?!#{RouteManager.login_route}$)} do			
			  content_type :json
			  #FIXME REMOVE	
        #puts "ENTRO BEFORE" 
        #pp request.env
        token  = ""
        cookie = ""
        
        #pp "TOKEN DESCAPADO = #{CGI::unescape(request.env['HTTP_CONTENT_MD5'])}"
        
        
        cookie = request.cookies[COOKIE_TOKEN_ID]        
        token = CGI::unescape(request.env['HTTP_CONTENT_MD5']) if request.env['HTTP_CONTENT_MD5']!=nil 
        
        #FIXME REMOVE
        # pp "COOKIES = #{cookie}"
        # pp "TOKEN = #{token}"
#                                   
        # pp "TIENE COOKIE " if (@session_table.has_key?(cookie))
        # pp "CONTIENE TOKEN " if (challenged?(token))
        
			  if (!@session_table.has_key?(cookie)|| 
			       !challenged?(token))			       				    		    
			    redirect to(RouteManager.login_route)
			    
			  else
			    #raise RestException.new(401,"Not authorized") if !authorized?(cookie,token)	    
			    halt 401, "Not authorized\n" if !authorized?(cookie,token)
			  end				   
			  clear_session_table
			end
			
			after %r{^(?!#{RouteManager.login_route}$)} do
			 
			 cookie=request.cookies[COOKIE_TOKEN_ID]
			 
			 @session_table.delete(cookie) if cookie!=nil
			 #FIXME REMOVE
			 #pp "-------------------------------------------"
			end
				
			######### FIXME DELETE #####################			
			get '/' do
					"Hello World"
			end		
			
			###############################################
		  get RouteManager.login_route do		    
        res = ClientController.send_challenge
        #FIXME REMOVE
        #puts "LOGIN"
        
        
        #@session_table[res[:cookie]]={:expiration => Time::now.to_i,:challenge=>res[:challenge]}
        #pp res[:cookie]
        @session_table[res[:cookie]]={:expiration => Time::now.to_i+COOKIE_EXPIRATION_TIME,:challenge=>res[:challenge]}
        #pp @session_table.inspect
        
        response.set_cookie(COOKIE_TOKEN_ID, res[:cookie])        
        headers "Content_MD5"   => res[:challenge]        
        status 200  	    
        
		    #handle_response_result(ClientController.send_challenge)
		  end
		  
			get RouteManager.box_list_route	do				
				#ClientController.listboxes.to_json
				execute(:listboxes)
			end

			delete RouteManager.box_delete_route do			  					
				#handle_response_result(ClientController.box_delete("params[:box]",params[:provider]))				
				execute(:box_delete,true,params[:box],params[:provider])
			end				
			
			post RouteManager.box_add_route do			  
				execute_async(:box_add,params[:box],params[:url])
			end
			
				
								
			get RouteManager.vm_status_all_route do
				#handle_response_result(ClientController.vm_status(nil))
				execute(:vm_status)
			end
			
				

			get RouteManager.vm_status_route do
				#handle_response_result(ClientController.vm_status(params[:vm]))
				execute(:vm_status,true,params[:vm])
			end
			
			#accept :vmname as paramter. This parameter
			#could be empty
			post RouteManager.vm_up_route do			  			  
			  execute_async(:vm_up,params[:vmname])
			end
				
			#accept :vmname and :force as paramters
			post RouteManager.vm_halt_route do
				#handle_response_result(ClientController.vm_halt(params[:vmname],params[:force]))
				execute_async(:vm_halt,params[:vmname],params[:force])        
			end
				
			#accept :vmname as paramter. This parameter
			#could be empty
			post RouteManager.vm_destroy_route do
				#handle_response_result(ClientController.vm_confirmed_destroy(params[:vmname]))
				execute(:vm_confirmed_destroy,true,params[:vmname])        
			end
			
			put RouteManager.vm_add_route do			  
        execute(:vm_add,false,params[:file],params[:rename])        
      end
      
      delete RouteManager.vm_delete_route do
        execute(:vm_delete,false,params[:vm],params[:remove])
      end
				
			#accept :vmname as paramter. This parameter
			#could be empty
			post RouteManager.vm_suspend_route do				
				#handle_response_result(ClientController.vm_suspend(params[:vmname]))
				execute_async(:vm_suspend,params[:vmname])        
			end
				
			#accept :vmname as paramter. This parameter
			#could be empty
			post RouteManager.vm_resume_route do					
				#handle_response_result(ClientController.vm_resume(params[:vmname]))
				execute_async(:vm_resume,params[:vmname])        
			end
			
			post RouteManager.vm_provision_route do
				#handle_response_result(ClientController.vm_provision(params[:vmname]))
				execute_async(:vm_provision,params[:vmname])        
			end
				
				
				
			get RouteManager.vm_sshconfig_route do				
				#handle_response_result(ClientController.vm_ssh_config(params[:vm]))
				execute(:vm_ssh_config,true,params[:vm])        
			end
				
			get RouteManager.snapshots_all_route do
				#handle_response_result(ClientController.vm_snapshots(nil))
				execute(:vm_snapshots,true)        
			end
			
					
			
			get RouteManager.vm_snapshots_route do
				#handle_response_result(ClientController.vm_snapshots(params[:vm]))
				execute(:vm_snapshots,true,params[:vm])        
			end
			
			get RouteManager.vm_snapshot_take_route do														
				#result=ClientController.vm_snapshot_take_file(params[:vmname])
				result=execute(:vm_snapshot_take_file,false,params[:vmname])
				
					
				send_file "#{result[1]}", :filename => result[1], 
									:type => 'Application/octet-stream' if result[0]==200 && params[:download]=="true"
				
				status result[0]
					
			end
			
						
			post RouteManager.vm_snapshot_take_route do			  
					#handle_response_result(ClientController.vm_snapshot_take(params[:vmname],params[:name],params[:desc]))					
					execute_async(:vm_snapshot_take,params[:vmname],params[:name],params[:desc])					      
			end
			
			
			post RouteManager.vm_snapshot_restore_route do
					#handle_response_result(ClientController.vm_snapshot_restore(params[:vmname],params[:snapid]))					
					execute_async(:vm_snapshot_restore,params[:vmname],params[:snapid])
			end
			
			delete RouteManager.vm_snapshot_delete_route do
        execute(:vm_snapshot_delete,false,params[:vm],params[:snapid])
      end
			
			
			get RouteManager.vm_backup_log_route do
				#handle_response_result(ClientController.backup_log(params[:vm]))
				execute(:backup_log,true,params[:vm])
			end
			
				

			get RouteManager.node_backup_log_route do
				#handle_response_result(ClientController.backup_log(nil))
				execute(:backup_log,true)
			end
			
			
			get RouteManager.config_show_route do
			  result= execute(:config_show,false)
			  #result=ClientController.config_show  
        
        send_file(result, :disposition => 'attachment', :filename => result)          
                        
      end
			
			post RouteManager.node_password_change_route do
			  execute(:password_change,false,params[:password])
			end
			
			post RouteManager.config_upload_route do			  
			  execute(:config_upload,false,params[:file])
			end
			
			get RouteManager.node_queue_route do			  
			  execute(:operation_queued,true,params[:id])
			end
			
			get RouteManager.node_queue_last_route do			  
        execute(:operation_queued_last,true)
      end
			
			
				
			private
			  def clear_session_table			   
			   @session_table.delete_if {|key,value| Time::now.to_i >= value[:expiration]}
			  end
			  
			  #FIXME Factorizar estos dos métodos
			  def execute_async(method,*params)
          begin 
            if params.empty?
              result=ClientController.send method.to_sym
            else              
              result=ClientController.send method.to_sym,*params
            end
            
            
            #pp result
            status 202
            body "Location: #{result}"
            # body "Location: #{result}".to_json                        
            
          rescue => e          
            #FIXME DELETE PUTS
            #puts "EN EXCEPCION"
             puts e.class
             puts e.message
             
            
             exception = ((e.class==RestException)? e:ExceptionMutator.new(e))           
            
             halt exception.code,exception.message           
          end
          
        end     
			  
			  #def execute(method,params = {} ,to_json = true)
			  def execute(method,to_json = true,*params)
			    begin	
			      if params.empty?
			        result=ClientController.send method.to_sym
			      else			        
			        result=ClientController.send method.to_sym,*params
			      end
            #puts "TERMINADA LA OPERACION"
            #puts "A JSON " if to_json
            #puts "resultado #{result}"
            return result.to_json if to_json
            result
            
			    rescue => e			     
			      #puts "EN EXCEPCION"
			       puts e.class
			      puts e.message
			       
			      
			      exception = ((e.class==RestException)? e:ExceptionMutator.new(e))			      
			      
			      halt exception.code,exception.message			      
			    end
			    
			  end		  
			  
			  
  			
  			def authorized?(id,token)  			  
  			  @session_table[id][:challenge]
  			  ClientController.authorized?(token,@session_table[id][:challenge]) if @session_table.has_key?(id)
  			end
  			
  			def challenged?(token)
  			  (token!=nil && token.size==32) 
  			end
				
			end
		end
	end
end
