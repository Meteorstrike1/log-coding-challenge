require_relative 'log_helper'
class InternalServiceLog
  attr_reader :service_name, :email_event, :timestamp, :json, :email

  class InvalidInternalServiceName < StandardError; end

  def initialize(valid_log)
    @email = valid_log['email']['to']
    @json = valid_log
    @email_event = valid_log['event'].to_sym
    @service_name = extract_internal_service_name(@email)
    @timestamp = valid_log['timestamp']
  end

private

  def extract_internal_service_name(email_address)
    raise InvalidInternalServiceName unless email_address.match?(LogHelper::INTERNAL_SERVICE_EMAIL_REGEX)

    email_address.match(LogHelper::INTERNAL_SERVICE_EMAIL_REGEX).named_captures['service']
  end
end
