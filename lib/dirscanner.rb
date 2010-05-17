#
# Dirscanner Class
# [Author] Bruno Milare
# [Date] 14.15.2010
#
require 'find'
require 'date'
require 'singleton'

# Project root path
ProjectPath =  File.expand_path(File.join(File.dirname(__FILE__), "../..")) << "/"


# Maintenance file path (relative)
# This file is responsible to keep track of new and out of date files.
# Do not change this path, it is relative and does not need to be changed.
DirMaintenance = "./"

# File to keep track of updates and new files.
FilenameLastChecked = ".tracking"


class Dirscanner
  
  include Singleton
  
  
  # [Method] scan_dir
  # [Desc] Keeps track of files, do all tasks, kind of singleton method
  def Dirscanner.scan( dir )
   
    if File.exists? dir 
       @@dir = dir if dir
    
       open_check_file

       check_files

       list_files
    else
       puts "Dirscanner::No such file or directory."
    end


  end
  
  
  # [Method] open_check_file
  # [Desc] Open the file which contains all info about last check
  def Dirscanner.open_check_file  
    
    begin
      last_checked_file = File.new( DirMaintenance + FilenameLastChecked )
    rescue => exec
      last_checked_file = File.new( DirMaintenance + FilenameLastChecked, "w+")    
    end
    
    generate_hash_of_filenames( last_checked_file )
    
  end
  
  
  # [Method] generate_hash_of_filenames
  # [Desc] Generate a hash of all files listed in the check file
  def Dirscanner.generate_hash_of_filenames( file )
    
    # current_filenames[filename] = modification time 
    @current_files = {}
    
    file.each_line do |line|
      current_file = line.split('$')[1]  
      current_timestamp = line.split('$')[2]
      @current_files[current_file] = current_timestamp
    end
    
    file.close
    
  end
  
  
  # [Method] get_file_timestamp
  # [Desc] Return the integer value of the timestamp 
  def Dirscanner.get_file_timestamp( filename )
    File.mtime( filename ).to_i 
  end
  
  
  # [Method] clear_maintenance_file
  # [Desc] Clear the check file 
  def Dirscanner.clear_maintenance_file 
    
    File.delete( DirMaintenance+FilenameLastChecked )
    maintenance_file = File.new( DirMaintenance+FilenameLastChecked, "w" )
    
  end
  
  # [Method] check_files
  # [Desc] Check if there is a new or updated file in the input dir
  def Dirscanner.check_files
    
    files = @current_files.keys
    timestamps = @current_files.values
    
    entries = []
    
    
    Find.find( @@dir ) do |f|
      if f != @@dir
        entries.push( f )
      end
    end
    
    entries.each do |entry|
      
      timestamp = get_file_timestamp( entry )
      
      # If the file is already in the dir
      if files.include? entry
        # Check timestamps
        if( timestamp > @current_files[entry].to_i )
          FilesHandler.instance.pushFiles( "update", entry, timestamp )
        elsif( timestamp == @current_files[entry].to_i )
          FilesHandler.instance.pushFiles( "keep", entry, timestamp )
        end      
        # If it is not
      else
        FilesHandler.instance.pushFiles( "new", entry, timestamp )
      end
    end 
    
    update_maintenance_file
    
  end  
  
  # [Method] update_maintenance_file
  # [Desc] Delete and rewite check file
  def Dirscanner.update_maintenance_file
    
    maintenance_desc = clear_maintenance_file
    
    FilesHandler.instance.aval_files.each do |f|
      maintenance_desc.puts "#{f[0]}$#{f[1]}$#{f[2]}"
    end
    
    maintenance_desc.close
    
  end
  
  # [Method] list_files
  # [Desc] Get new and upated files from input
  def Dirscanner.list_files  
    @@aval_files_str = {}
    @@aval_files_str["new"] = []
    @@aval_files_str["kept"] = []
    @@aval_files_str["updated"] = []
    
    FilesHandler.instance.aval_files.each do |file|
      # file content => [action, file_path, timestamp]
      if ( file[0] == "keep" )
        @@aval_files_str["kept"].push( file[1] )
      elsif ( file[0] == "new" )
        @@aval_files_str["new"].push( file[1] )
      elsif ( file[0] == "update" )
        @@aval_files_str["updated"].push( file[1] )
      end
    end
    
    FilesHandler.instance.clear

    return @@aval_files_str
  end
  
end


class FilesHandler
  
  include Singleton
  
  @@aval_files = []
  
  # [Method] pushFiles
  # [Desc] Push new files to the list of available files
  def pushFiles(action, file_path, timestamp)
    tmp_file_info = [action, file_path, timestamp]
    @@aval_files.push( tmp_file_info )
    
  end
  
  # [Method] aval_files
  # [Desc] Return available files
  def aval_files
    @@aval_files
  end

  def clear
    @@aval_files = []
  end
  

end
