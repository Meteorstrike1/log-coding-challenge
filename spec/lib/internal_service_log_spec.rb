RSpec.describe InternalServiceLog do
  subject { described_class }

  internal_service_email_log = {
    'timestamp' => '2025-08-01T00:00:08.000Z',
    'level' => 'INFO',
    'service' => 'email-template-service',
    'event' => 'email_sent',
    'requestId' => '9be77672-be04-4531-95d9-8b0bc253fece',
    'email' => {
      'to' => 'payment-gateway.3f2aa239fb51a4de8b38a87edfc2e9e3@dvla.net',
      'subject' => 'Reminder',
      'template' => 'invoice',
      'provider' => 'amazon-ses',
    },
    'userId' => '012839',
    'durationMs' => 1271,
    'status' => 200,
  }

  internal_personal_email_log = {
    'timestamp' => '2025-08-02T00:00:08.000Z',
    'level' => 'INFO',
    'service' => 'email-template-service',
    'event' => 'email_sent',
    'requestId' => '9be77672-be04-4531-95d9-8b0bc253fece',
    'email' => {
      'to' => 'anne.3f2aa239fb51a4de8b38a87edfc2e9e3@dvla.net',
      'subject' => 'Hello',
    },
    'userId' => '012829',
    'durationMs' => 1171,
    'status' => 200,
  }

  it 'will create an object from a log with an internal service email' do
    expect { subject.new(internal_service_email_log) }.to_not raise_error
  end

  it 'will have a service name' do
    expect(subject.new(internal_service_email_log).service_name).to eq('payment-gateway')
  end

  it 'will raise an error if try to create an object from a log with an internal personal email' do
    expect { subject.new(internal_personal_email_log) }.to raise_error(InternalServiceLog::InvalidInternalServiceName)
  end
end
