## Log parsing coding challenge
Project to validate email event logs against JSON schema and then analyse the performance of the email sending system

### Overview
- [App](lib/app.rb) - Main program, run to analyse the logs and get the output in terminal (which also gets saved to a text file in out folder)
- [LogHelper](lib/log_helper.rb) - Module of methods to help process the logs and create InternalServiceLog and InternalService objects 
- [InternalServiceLog](lib/internal_service_log.rb) - Class to represent a valid log for emails sent to internal services
- [InternalService](lib/internal_service.rb) - Class to represent an internal service and its email event information
- [DataLoader](lib/data_loader.rb) - Module to load the file
- [SchemaParser](lib/schema_parser.rb) - Module of methods to parse JSON logs and validate against the schema
- [Schema](schema) - JSON schema based on the specifications of what is necessary for a log to be valid
- [Dataset](data/email_event_logs_dataset.txt) - Text file containing the email event logs


### Setup
1. Install gems
```bash
  bundle install
```

2. Run app.rb from lib directory
```bash
  ruby lib/app.rb
```

Unit tests can be run with `bundle exec rspec`

