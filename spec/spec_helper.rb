$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
require 'pry'
require 'vcr'

ENV['SECRETS_FILE'] = 'spec/files/ymls/secrets.yml'

require 'shia'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = { record: :new_episodes }
end

if ENV['COVERAGE']
  coverage_goal = 95

  RSpec.configure do |config|
    config.after(:suite) do
      example_group = RSpec.describe('Code coverage')
      example = example_group.example("must be above #{coverage_goal}%") do
        expect(SimpleCov.result.covered_percent).to be > coverage_goal
      end
      example_group.run
      passed = example.execution_result.status == :passed
      RSpec.configuration.reporter.example_failed example unless passed
    end
    config.order = :random
  end
end
