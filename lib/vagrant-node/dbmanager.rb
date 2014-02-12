require 'sqlite3'
require 'digest/md5'
module Vagrant
	module Node
		module DB
			class DBManager
				
				def initialize(data_dir)
					@db=check_database(data_dir)
				end
				
				def get_backup_log_entries(vmname)
					sql="SELECT * FROM #{BACKUP_TABLE_NAME}"
					sql = sql + " WHERE #{BACKUP_VM_NAME_COLUMN} = \"#{vmname}\"" if vmname					
					
					#return rows
					@db.execute(sql)
					
				end
				
				def add_backup_log_entry(date,vmname,status)
					sql="INSERT INTO #{BACKUP_TABLE_NAME} VALUES ( ? , ? , ? )"					
					@db.execute(sql,date,vmname,status)
				end
				
				def update_backup_log_entry(date,vmname,status)					
					sql="UPDATE #{BACKUP_TABLE_NAME} SET #{BACKUP_STATUS_COLUMN} = ? WHERE #{BACKUP_DATE_COLUMN}= ? AND #{BACKUP_VM_NAME_COLUMN}= ?"
					@db.execute(sql,status,date,vmname)					
				end
	 			
	 			def node_password_set?
	 			  sql="SELECT Count(*) FROM #{PASSWORD_TABLE};"
	 			  
	 			  return @db.execute(sql).first[0]!=0
	 			  #return true
	 			  
	 			end
      
        def node_check_password?(old_password)
          sql="SELECT #{PASSWORD_COLUMN} FROM #{PASSWORD_TABLE} LIMIT 1;"
          stored_pwd=@db.execute(sql)
          
          return (stored_pwd.length!=0 && (stored_pwd.first[0]==Digest::MD5.hexdigest(old_password)))  
          #return true
        end
        
        def node_password
          sql="SELECT #{PASSWORD_COLUMN} FROM #{PASSWORD_TABLE} LIMIT 1;"
          stored_pwd=@db.execute(sql)
          stored_pwd.first[0]  
        end
        
        def node_password_set(new_password,raw=false)          
          if node_password_set?  || !node_default_password_set?        
            sql="UPDATE #{PASSWORD_TABLE} SET #{PASSWORD_COLUMN} = ? "
          else            
            sql="INSERT INTO #{PASSWORD_TABLE} VALUES (?)"
          end
          
          @db.execute(sql,
                      ((raw)? new_password:
                             Digest::MD5.hexdigest(new_password)))
            
        end

        def node_default_password_set?
          return node_password == DEFAULT_NODE_PASSWORD 
        end


        def create_queued_process(id)
          sql="INSERT INTO #{OPERATION_QUEUE_TABLE_NAME} VALUES (?, ?, ?, ?, ?)"
          @db.execute(sql,id,Time.now.strftime("%Y-%m-%d") ,Time.now.to_i,PROCESS_IN_PROGRESS,"")          
        end
        
        def set_queued_process_result(id,result)
          sql="UPDATE #{OPERATION_QUEUE_TABLE_NAME} SET #{OPERATION_STATUS_COLUMN} = ?,#{OPERATION_RESULT_COLUMN} = ?  WHERE #{OPERATION_ID_COLUMN}= ?"          
          @db.execute(sql,PROCESS_SUCCESS,result,id)
        end
        
        def set_queued_process_error(id,exception)          
          sql="UPDATE #{OPERATION_QUEUE_TABLE_NAME} SET #{OPERATION_STATUS_COLUMN} = ?,#{OPERATION_RESULT_COLUMN} = ?  WHERE #{OPERATION_ID_COLUMN}= ?"
          @db.execute(sql,PROCESS_ERROR,exception.message,id)
        end
        
        def get_queued_process_result(id)
          sql="SELECT #{OPERATION_STATUS_COLUMN},#{OPERATION_RESULT_COLUMN} FROM #{OPERATION_QUEUE_TABLE_NAME} WHERE #{OPERATION_ID_COLUMN}= ?;"
          #sql="SELECT * FROM #{OPERATION_QUEUE_TABLE_NAME};"
          @db.execute(sql,id)          
        end
        
        def get_queued_last
          sql="SELECT #{OPERATION_STATUS_COLUMN},#{OPERATION_RESULT_COLUMN} FROM #{OPERATION_QUEUE_TABLE_NAME};"
          @db.execute(sql)
        end
        
        
        def remove_queued_processes
          sql="DELETE FROM #{OPERATION_QUEUE_TABLE_NAME}"
          @db.execute(sql)          
        end
        

				private
			
			  PROCESS_IN_PROGRESS = 100;
			  PROCESS_SUCCESS = 200;
			  PROCESS_ERROR = 500;
			
				BACKUP_TABLE_NAME='node_table'
				BACKUP_DATE_COLUMN = 'date'
				BACKUP_VM_NAME_COLUMN = 'vm_name'
				BACKUP_STATUS_COLUMN = 'backup_status'
				PASSWORD_TABLE = 'node_password_table'
				PASSWORD_COLUMN = 'node_password'
				DEFAULT_NODE_PASSWORD = 'catedrasaesumu'
				
				OPERATION_QUEUE_TABLE_NAME='operation_queue_table'
				OPERATION_CMD_COLUMN = 'operation_cmd'
				OPERATION_STATUS_COLUMN = 'operation_status'
				OPERATION_RESULT_COLUMN = 'operation_result'
				OPERATION_ID_COLUMN = 'operation_id'
				OPERATION_DATE_COLUMN = 'operation_date'				
				OPERATION_TIME_COLUMN = 'operation_time'
				
				def check_database(data_dir)					
					#Creates and/or open the database
					
					db = SQLite3::Database.new( data_dir.to_s + "/node.db" )
					#Trying to avoid the sqlite3::busyexception
					db.busy_timeout=100;
									
					if db.execute("SELECT name FROM sqlite_master 
											 WHERE type='table' AND name='#{BACKUP_TABLE_NAME}';").length==0						
						db.execute( "create table '#{BACKUP_TABLE_NAME}' (#{BACKUP_DATE_COLUMN} TEXT NOT NULL, 
												 																#{BACKUP_VM_NAME_COLUMN} TEXT PRIMARY_KEY,
												 																#{BACKUP_STATUS_COLUMN} TEXT NOT NULL);" )
												 																
            
												 																
												 																
					end
					
					
					if db.execute("SELECT name FROM sqlite_master 
                       WHERE type='table' AND name='#{PASSWORD_TABLE}';").length==0            
            db.execute("create table '#{PASSWORD_TABLE}' (#{PASSWORD_COLUMN} TEXT NOT NULL);" )
            db.execute("INSERT INTO #{PASSWORD_TABLE} VALUES (\"#{DEFAULT_NODE_PASSWORD}\");");            
          end
					
					if db.execute("SELECT name FROM sqlite_master 
                       WHERE type='table' AND name='#{OPERATION_QUEUE_TABLE_NAME}';").length==0
					
		         # db.execute( "create table '#{OPERATION_QUEUE_TABLE_NAME}' (#{OPERATION_ID_COLUMN} INTEGER PRIMARY_KEY,
		                                                    # #{OPERATION_CMD_COLUMN} TEXT NOT NULL,
		                                                    # #{OPERATION_DATE_COLUMN} TEXT NOT NULL,
		                                                    # #{OPERATION_TIME_COLUMN} INTEGER NOT NULL,
                                                        # #{OPERATION_STATUS_COLUMN} TEXT NOT NULL,
                                                        # #{OPERATION_RESULT_COLUMN} TEXT NOT NULL);" )
               db.execute( "create table '#{OPERATION_QUEUE_TABLE_NAME}' (#{OPERATION_ID_COLUMN} INTEGER PRIMARY_KEY,                                                        
                                                        #{OPERATION_DATE_COLUMN} TEXT NOT NULL,
                                                        #{OPERATION_TIME_COLUMN} INTEGER NOT NULL,
                                                        #{OPERATION_STATUS_COLUMN} INTEGER NOT NULL,
                                                        #{OPERATION_RESULT_COLUMN} TEXT NOT NULL);" )
                                                        
          end
					
					
					db
					
				end
						
			end
		end
	end
end
