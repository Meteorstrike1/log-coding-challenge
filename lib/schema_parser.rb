require 'json_schemer'
require 'pathname'

module SchemaParser
  SCHEMA_PATH = Pathname(__dir__).join('../schema/email-log-schema.json')

  def self.load_schema
    JSONSchemer.schema(File.read(SCHEMA_PATH))
  end

  def self.validate_against_schema(schema, json)
    schema.validate(json).to_a
  end

  def self.validate_logs(logs, schema)
    missing_email_count = 0
    invalid_json_count = 0
    invalid_log_count = 0
    valid_logs = []
    logs.each do |log|
      json = JSON.parse(log)
      output = schema.validate(json).to_a
      if output.empty?
        # Save logs with valid structure
        valid_logs << json
      else
        # Logs with invalid structure
        missing_email_count += 1 unless json.key?('email')
        invalid_log_count += 1
      end
    rescue JSON::ParserError
      # Logs which are malformed JSON
      invalid_json_count += 1
    end
    [valid_logs, missing_email_count, invalid_json_count, invalid_log_count]
  end

  # TODO: If time add some of the error reading stuff from library
end
