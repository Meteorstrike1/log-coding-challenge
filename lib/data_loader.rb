require 'pathname'

module DataLoader
  FILE_PATH = 'data/email_event_logs_dataset.txt'.freeze

  def self.load_file
    File.readlines(FILE_PATH, chomp: true)
  end
end
