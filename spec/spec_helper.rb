require 'database_cleaner'
# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
require 'faker'
require 'capybara_remote'
require 'capybara/poltergeist'
require 'selenium-webdriver'
require_relative './support/wait_for_ajax'
require_relative './support/wait_for_authentication'
require_relative './support/wait_for_modal'
require_relative 'helpers/download_helpers'

#Capybara.default_max_wait_time = 5

#to run a test from a different timezone, specify it in the command line like this:
#   TZ=Pacific/Apia rspec spec/feature/timezone.spec
# to confirm, uncomment this line:
# puts ENV['TZ']

Capybara.register_driver :chrome do |app|
  caps = Selenium::WebDriver::Remote::Capabilities.chrome(
    "chromeOptions" => {
      "args" => [ "--window-size=1400,800"],
      "prefs" => {"download.default_directory" => DownloadHelpers::PATH }
    }
  )
  Capybara::Selenium::Driver.new(app, :browser => :chrome, :desired_capabilities => caps)
end

Capybara.register_driver :poltergeist do |app|
# use this configuration to show the messages between poltergeist and phantomjs
  #Capybara::Poltergeist::Driver.new(app, :debug => true)
# use this configuration to enable the page.driver.debug interface
# see https://github.com/teampoltergeist/poltergeist
  #Capybara::Poltergeist::Driver.new(app, :inspector => true, :timeout => 300)
  Capybara::Poltergeist::Driver.new(:window_size => [1600,900])
end

url = CapybaraRemote.url # it's in lib directory
capabilities = Selenium::WebDriver::Remote::Capabilities.internet_explorer
capabilities.version = "11"

Capybara.register_driver :remote do |app|
  Capybara::Selenium::Driver.new(app,
    :browser => :remote,
    :url => url,
    :desired_capabilities => capabilities)
end

if ENV["client"] =~ /(sel|ff)/i
  puts "Browser: Firefox via Selenium"
  Capybara.javascript_driver = :selenium
elsif ENV["client"] =~ /chr/i
  puts "Browser: Chrome"

  Capybara.javascript_driver = :chrome
elsif ENV["client"] =~ /ie/i
  puts "Browser: IE"
  CONFIGURATION FOR REMOTE TESTING OF IE
  require 'capybara/rspec'


  Capybara.server_port = 3010
  ip = `ifconfig | grep 'inet ' | grep -v 127.0.0.1 | cut -d ' ' -f2`.strip
  puts "this machine ip is #{ip}"

  Capybara.app_host = "http://#{ip}:#{Capybara.server_port}"
  Capybara.current_driver = :remote
  Capybara.javascript_driver = :remote
  Capybara.run_server = false
  Capybara.remote = true

else
  puts "Browser: Phantomjs via Poltergeist"

  Capybara.javascript_driver = :poltergeist
end

#require 'simplecov'
#SimpleCov.start

# config for firefox with port 3010
#require 'capybara/rspec'
#Capybara.server_port = 3010
# /config

RSpec.configure do |config| # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end

  config.backtrace_exclusion_patterns = [
    /rspec-(core|expectations|matchers|mocks|rails)/
  ]

  config.before(:suite) do
    begin
      DatabaseCleaner.clean_with(:truncation)
      #Controller.update_table
      #%w[developer, admin, staff].each do |role|
        #Role.create(:name => role)
      #end
    rescue DatabaseCleaner::NoORMDetected
    end
  end

  #config.around(:each) do |example|
    #DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    #DatabaseCleaner.start
    #example.run
    #DatabaseCleaner.clean
  #end

  # see https://github.com/DatabaseCleaner/database_cleaner/issues/273
  # note that @jfine suggests deletion, but truncation seems to work
  # I can't imagine why this works but the around hooks above do not
  config.before(:each) do |example|
    begin
      DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
      #DatabaseCleaner.strategy = example.metadata[:js] ? :deletion : :transaction
      DatabaseCleaner.start
      Rails.root.join('tmp', 'cache').children.each{|dir| FileUtils.remove_dir(dir) unless dir.to_s.match(/assets/)}
    rescue DatabaseCleaner::NoORMDetected
    end
  end
  config.after(:each) do
    begin
      DatabaseCleaner.clean
      Rails.root.join('tmp', 'cache').children.each{|dir| FileUtils.remove_dir(dir) unless dir.to_s.match(/assets/)}
      Rails.root.join('tmp', 'uploads', 'store').children.each{|file| FileUtils.rm(file)}
    rescue DatabaseCleaner::NoORMDetected
    end
  end

end
