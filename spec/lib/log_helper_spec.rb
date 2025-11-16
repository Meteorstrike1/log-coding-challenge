RSpec.describe LogHelper do
  include LogHelper

  context 'extract_internal_service_logs' do
    it 'only includes returns objects for valid internal service logs' do
      file_path = "#{RSPEC_ROOT}/fixtures/test_logs.txt"
      schema = SchemaParser.load_schema
      logs = DataLoader.load_file(file_path:)
      valid_logs, _invalid_logs = SchemaParser.validate_logs(logs, schema)
      expect(valid_logs.count).to eq(4)
      expect(LogHelper.extract_internal_service_logs(valid_logs).count).to eq(2)
    end
  end
end
