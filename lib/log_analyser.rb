module LogAnalyser
  INTERNAL_EMAIL_REGEX = /(?<service>(?=\w+-|\w+_)[\w-]+)\.(?<uuid>[0-9a-zA-Z-]+)@dvla\.(?<domain>\w+)/

  class InvalidInternalServiceName < StandardError; end

  # TODO: Need to split anything into a different module?

  # Total the events key of an array of logs
  # @param logs [Array<Hash>]
  def self.sum_events(logs)
    events = {
      email_sent: 0,
      email_queued: 0,
      email_failed: 0,
    }
    logs.each do |log|
      events[log['event'].to_sym] += 1
    end
    events
  end

  def self.internal_service_emails(logs)
    logs.select { |log| log['email']['to'].match?(INTERNAL_EMAIL_REGEX) }
  end

  def self.extract_internal_service_name(email_address)
    raise InvalidInternalServiceName unless email_address.match?(INTERNAL_EMAIL_REGEX)

    email_address.match(INTERNAL_EMAIL_REGEX).named_captures['service']
  end

  # Extract service name and organise email events per internal service
  # @param logs [Array<Hash>]
  # @return [Hash<String, Hash>]
  def self.events_by_internal_service(logs)
    # Initialise a hash with each email event set to zero
    events_per_service = Hash.new { |hash, key| hash[key] = { email_sent: 0, email_queued: 0, email_failed: 0 } }

    # Grab service name from capture and update running total for event type
    logs.each do |log|
      service_name = extract_internal_service_name(log['email']['to'])
      current_total = events_per_service[service_name]
      current_total[log['event'].to_sym] += 1
      events_per_service[service_name] = current_total
    end
    events_per_service
  end

  # @param services [Hash<String, Hash>]
  # @return Hash<String, Float>
  def self.success_rate_per_service(services)
    success_rates = {}
    services.each do |service_name, event_breakdown|
      success_rates[service_name] = calculate_success_rate(event_breakdown)
    end
    success_rates
  end

  # How do you define success rate then? Is it non fails or emails sent/total?
  # @return float
  def self.calculate_success_rate(events)
    total = events.values.sum.to_f
    (events[:email_sent].to_f / total) * 100
  end

  def self.calculate_failure_rate(events)
    total = events.values.sum.to_f
    (events[:email_failed].to_f / total) * 100
  end

  # @param service_name [String]
  # @param success_rate [Float]
  # @return [String]
  def self.output_success_rate(service_name, success_rate)
    "#{service_name} - #{format('%.2f', success_rate)}%"
  end

  # @param service_name [String]
  # @param hour [Integer]
  # @param failure_rate [Float]
  # @return [String]
  def self.output_failures_rate(service_name, hour, failure_rate)
    "Highest failure rate for #{service_name} was at #{hour} hours with #{format('%.2f', failure_rate)}%"
  end

  # Creates a hash where the default value is a hash 0-23 keys and default of 0 (to allow addition of email events per hour)
  # @return Hash
  def self.hash_with_hours_default
    Hash.new do |hash, key|
      hours_hash = {}
      hours = (0..23).to_a
      hours.each do |hour|
        hours_hash[hour] = Hash.new(0)
      end
      hash[key] = hours_hash
    end
  end

  # Uses hash created by hash_with_hours_default, goes through logs and updates email event type total for that hour for the service
  # @param events_per_hour [Hash<String, Hash>]
  def self.service_event_type_per_hour(internal_service_logs)
    events_per_hour = hash_with_hours_default
    internal_service_logs.each do |log|
      hour = DateTime.parse(log['timestamp']).hour
      event = log['event'].to_sym
      service_name = extract_internal_service_name(log['email']['to'])
      events_per_hour[service_name][hour][event] += 1
    end
    events_per_hour
  end

  def self.service_failure_rate_per_hour(events_per_hour)
    events_per_hour.transform_values do |hour_events|
      hour_events.each do |key, events|
        hour_events[key] = calculate_failure_rate(events)
      end
    end
  end
end
