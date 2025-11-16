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
    valid_logs = []
    invalid_logs = {
      missing_email: 0,
      invalid_schema: 0,
      malformed_json: 0,
    }
    logs.each do |log|
      json = JSON.parse(log)
      output = schema.validate(json).to_a
      if output.empty?
        # Save logs with valid structure
        valid_logs << json
      else
        # Logs with invalid structure
        invalid_logs[:missing_email] += 1 unless json.key?('email')
        invalid_logs[:invalid_schema] += 1
      end
    rescue JSON::ParserError
      # Logs which are malformed JSON
      invalid_logs[:malformed_json] += 1
    end
    [valid_logs, invalid_logs]
  end

  # TODO: If time add some of the error reading stuff from library
end
