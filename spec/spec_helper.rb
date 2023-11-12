# frozen_string_literal: true

require "bloomy"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.filter_sensitive_data('<USERNAME>') { ENV['USERNAME'] }
  config.filter_sensitive_data('<PASSWORD>') { ENV['PASSWORD'] }
  config.filter_sensitive_data('<MEETING_ID>') { ENV['MEETING_ID'] }
  config.filter_sensitive_data('<API_KEY>') { ENV['API_KEY'] }
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around(:each, :vcr) do |example|
    VCR.use_cassette(example.metadata[:full_description].split(/\s+/, 2).join("/")) do
      example.run
    end
  end
end
