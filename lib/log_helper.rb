require_relative 'internal_service_log'
require_relative 'internal_service'

module LogHelper
  INTERNAL_SERVICE_EMAIL_REGEX = /(?<service>(?=\w+-|\w+_)[\w-]+)\.(?<uuid>[0-9a-zA-Z-]+)@dvla\.(?<domain>\w+)/

  # Filter the logs and create an InternalServiceLog object for any which have been sent to an internal service email
  # @param valid_logs [Array<Hash>] valid logs that have passed JSON schema
  # @return [Array<InternalServiceLog>]
  def self.extract_internal_service_logs(valid_logs)
    internal_service_logs = valid_logs.select { |log| log['email']['to'].match?(INTERNAL_SERVICE_EMAIL_REGEX) }
    internal_service_logs.map { |internal_log| InternalServiceLog.new(internal_log) }
  end

  # Total the events key of an array of InternalServiceLog objects
  # @param logs [InternalServiceLog]
  # @return [Hash<Symbol, Integer>]
  def self.sum_events(internal_service_logs)
    events = {
      email_sent: 0,
      email_queued: 0,
      email_failed: 0,
    }
    internal_service_logs.each do |log|
      events[log.email_event] += 1
    end
    events
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

  # Go through individual internal service logs and create a summary per service
  # @param internal_service_logs [Array<InternalServiceLog>]
  # @return [InternalService]
  def self.summarise_internal_service(internal_service_logs)
    # Initialise a hash with each email event set to zero to enable collecting a running total
    events_per_service = Hash.new { |hash, key| hash[key] = { email_sent: 0, email_queued: 0, email_failed: 0 } }
    # Create hash for saving email events per hour
    events_per_hour = hash_with_hours_default

    # Update both overall events per service and events for each service per hour
    internal_service_logs.each do |log|
      current_total = events_per_service[log.service_name]
      current_total[log.email_event] += 1
      events_per_service[log.service_name] = current_total
      hour = DateTime.parse(log.timestamp).hour
      events_per_hour[log.service_name][hour][log.email_event] += 1
    end
    # For each service create an InternalService object with the service name and event data
    internal_services = []
    events_per_service.each_key do |service_name|
      internal_services << InternalService.new(service_name, events_per_service[service_name], events_per_hour[service_name])
    end
    internal_services
  end

  # @param events [Hash<Symbol, Integer>]
  # @return float
  def self.calculate_success_rate(events)
    total = events.values.sum.to_f
    (events[:email_sent].to_f / total) * 100
  end

  # @param events [Hash<Symbol, Integer>]
  # @return float
  def self.calculate_failure_rate(events)
    total = events.values.sum.to_f
    (events[:email_failed].to_f / total) * 100
  end
end
