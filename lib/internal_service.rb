require_relative 'log_helper'

class InternalService
  attr_reader :service_name, :email_events, :email_events_per_hour, :success_rate, :failure_rate_per_hour

  def initialize(service_name, email_events, email_events_per_hour)
    @service_name = service_name
    @email_events = email_events
    @email_events_per_hour = email_events_per_hour
    @success_rate = LogHelper.calculate_success_rate(@email_events)
    @failure_rate_per_hour = calculate_failure_rate_per_hour(email_events_per_hour)
  end

  def output_overall_success_rate
    "#{@service_name} - #{format('%.2f', @success_rate)}%"
  end

  def output_highest_failure_rate_hour
    hash = highest_failure_rate_per_hour
    "Highest failure rate for #{@service_name} was at #{hash[:hour]} hours with #{format('%.2f', hash[:failure_rate])}%"
  end

private

  def calculate_failure_rate_per_hour(email_events_per_hour)
    email_events_per_hour.transform_values do |hour_events|
      LogHelper.calculate_failure_rate(hour_events)
    end
  end

  def highest_failure_rate_per_hour
    hour, failure_rate = @failure_rate_per_hour.min_by { |_key, value| -value }
    { hour:, failure_rate: }
  end
end
