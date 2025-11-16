require_relative 'config'
require_relative 'data_loader'
require_relative 'log_analyser'
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
internal_service_logs = LogAnalyser.internal_service_emails(valid_logs)
total_events = LogAnalyser.sum_events(internal_service_logs)
overall_success = LogAnalyser.calculate_success_rate(total_events)
LOG.info { "Overall success rate for internal services: #{format('%.2f', overall_success)}%".green }

events_per_service = LogAnalyser.events_by_internal_service(internal_service_logs)
success_per_service = LogAnalyser.success_rate_per_service(events_per_service)
descending_order = success_per_service.sort_by { |_key, value| -value }
highest_success_rate_service = LogAnalyser.output_success_rate(descending_order.first[0], descending_order.first[1])
LOG.info { "The internal service with the highest success rate is: #{highest_success_rate_service.magenta}".green }

# TODO: Tidy these up
events_per_hour = LogAnalyser.service_event_type_per_hour(internal_service_logs)
failure_rate_per_hour = LogAnalyser.service_failure_rate_per_hour(events_per_hour)
failure_ordered = failure_rate_per_hour.transform_values do |hours|
  hours.sort_by { |_key, value| -value }
end
failure_ordered.each do |key, value|
  LOG.info { LogAnalyser.output_failures_rate(key, value.first[0], value.first[1]).brown }
end
