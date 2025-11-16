require_relative 'config'
require_relative 'data_loader'
require_relative 'log_helper'
require_relative 'schema_parser'

schema = SchemaParser.load_schema
logs = DataLoader.load_file

valid_logs, invalid_logs = SchemaParser.validate_logs(logs, schema)

# Dataset parsing
LOG.info { "Total valid logs: #{valid_logs.count}".green }
LOG.debug { "Invalid logs due to malformed JSON: #{invalid_logs[:malformed_json]}".red }
LOG.debug { "Invalid logs due to not matching the JSON schema: #{invalid_logs[:invalid_schema]}".red }
LOG.debug { "Total invalid logs: #{invalid_logs[:malformed_json] + invalid_logs[:invalid_schema]}".red }
LOG.info { "Invalid logs due to missing email key: #{invalid_logs[:missing_email]}".red }

# Valid log analysis
internal_service_logs = LogHelper.extract_internal_service_logs(valid_logs)
total_events = LogHelper.sum_events(internal_service_logs)
overall_success = LogHelper.calculate_success_rate(total_events)
LOG.info { "Overall success rate for internal services: #{format('%.2f', overall_success)}%".green }

internal_services = LogHelper.summarise_internal_service(internal_service_logs)
descending_order = internal_services.sort_by { |service| -service.success_rate }
LOG.info { "The internal service with the highest success rate is: #{descending_order.first.output_overall_success_rate.magenta}".green }

internal_services.each do |service|
  LOG.info { service.output_highest_failure_rate_hour.brown }
end
