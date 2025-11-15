require_relative 'data_loader'
require_relative 'schema_parser'
require_relative 'log_analyser'

schema = SchemaParser.load_schema
logs = DataLoader.load_file

valid_logs, missing_email_count, invalid_json_count, invalid_log_count = SchemaParser.validate_logs(logs, schema)

# Dataset parsing
puts "Valid log count: #{valid_logs.count}"
puts "Failing logs due to malformed JSON: #{invalid_json_count}"
puts "Logs with invalid structure: #{invalid_log_count}"
puts "Total invalid logs: #{invalid_log_count + invalid_json_count}"
puts "Failing logs due to missing email key: #{missing_email_count}"

# Valid log analysis
internal_service_logs = LogAnalyser.internal_service_emails(valid_logs)
total_events = LogAnalyser.sum_events(internal_service_logs)
overall_success = LogAnalyser.calculate_success_rate(total_events)
puts "Overall success rate for internal services: #{format('%.2f', overall_success)}%"

events_per_service = LogAnalyser.events_by_internal_service(internal_service_logs)
success_per_service = LogAnalyser.success_rate_per_service(events_per_service)
descending_order = success_per_service.sort_by { |_key, value| -value }
highest_success_rate_service = LogAnalyser.output_success_rate(descending_order.first[0], descending_order.first[1])
puts "The internal service with the highest success rate is: #{highest_success_rate_service}"

# TODO: Tidy these up
events_per_hour = LogAnalyser.service_event_type_per_hour(internal_service_logs)
failure_rate_per_hour = LogAnalyser.service_failure_rate_per_hour(events_per_hour)
failure_ordered = failure_rate_per_hour.transform_values do |hours|
  hours.sort_by { |_key, value| -value }
end
failure_ordered.each do |key, value|
  puts LogAnalyser.output_failures_rate(key, value.first[0], value.first[1])
end
