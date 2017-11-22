require "file_utils"
require "logger"

BACKUP_FOLDER_ROOT = "./backups"
DEFAULT_MAX_BACKUP_FOLDERS = 30
LOGFILE_PATH = "log"
LOG = Logger.new(File.new(LOGFILE_PATH, "a"))

# TODO Put your code here
def supervise
  return unless check_args?

  output_path = make_backup_folder
  LOG.info "output_path: #{output_path}"
  trigger_mongodump(output_path)
  cleanup_extra_folders
  LOG.info "Done"
end


def check_args?
  if ARGV.empty?
    puts "Missing valid hostname"
    return false
  end


  return true
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

def mongo_cmd(output_path)
  hostname = ARGV[0]
  "mongodump -h #{hostname} -o #{output_path}"
end

def trigger_mongodump(output_path)
  cmd = mongo_cmd(output_path)
  puts "cmd: #{cmd}"

  output = IO::Memory.new
  Process.run(cmd, shell: true, output: output, error: output)

  output.close
  LOG.info(output.to_s)
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
  sorted_folder_entries.size >= DEFAULT_MAX_BACKUP_FOLDERS
end

def remove_older_folders
  paths_to_remove = sorted_folder_entries.first(sorted_folder_entries.size - DEFAULT_MAX_BACKUP_FOLDERS)
  LOG.info "Deleting old folders: #{paths_to_remove}"
  paths_to_remove.each do |path| 
    FileUtils.rm_rf File.join(BACKUP_FOLDER_ROOT, path)
  end
end

supervise