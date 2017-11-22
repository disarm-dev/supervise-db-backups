require "file_utils"
require "./supervise-db-backups/*"

BACKUP_FOLDER_ROOT = "./backups"
MAX_BACKUP_FOLDERS = 100
MONGODUMP_CMD_ROOT = "mongodump -d douma_production -o"

# TODO Put your code here
def supervise
  current_path = make_backup_folder
  trigger_mongodump(current_path)
  cleanup_extra_folders
end

def backup_path
  now = Time.now
  day_level = now.to_s("%Y-%m-%d")
  minute_level = now.to_s("%H%M%S")
  File.join(BACKUP_FOLDER_ROOT, day_level, minute_level)
end

def make_backup_folder
  Dir.mkdir_p backup_path
  backup_path
end

def trigger_mongodump(current_path)
  output = IO::Memory.new
  cmd = "#{MONGODUMP_CMD_ROOT} #{current_path}"
  puts "cmd: #{cmd}"
  Process.run(cmd, shell: true, output: output)
  puts output.to_s
end

def cleanup_extra_folders
  if need_to_cleanup
    remove_older_folders
  end
end

def sorted_folder_entries
  (Dir.entries(BACKUP_FOLDER_ROOT) - %w[. ..]).sort
end

# Find all backup folders
def need_to_cleanup
  sorted_folder_entries.size >= MAX_BACKUP_FOLDERS
end

def remove_older_folders
  paths_to_remove = sorted_folder_entries.first(sorted_folder_entries.size - MAX_BACKUP_FOLDERS)
  paths_to_remove.each do |path| 
    FileUtils.rm_rf File.join(BACKUP_FOLDER_ROOT, path)
  end
end

supervise