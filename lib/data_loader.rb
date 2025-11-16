module DataLoader
  FILE_PATH = 'data/email_event_logs_dataset.txt'.freeze

  def self.load_file(file_path: FILE_PATH)
    File.readlines(file_path, chomp: true)
  end
end
