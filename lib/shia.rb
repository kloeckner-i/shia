require 'optparse'
require 'ostruct'
require 'logger'
require 'yaml'
require 'colorize'
require 'docker_registry2'
require 'rancher/api'
require 'shia/environment'
require 'shia/version'
require 'shia/config'
require 'shia/logger'
require 'shia/options'
require 'shia/repo'
require 'shia/ranch'

module Shia
  ALLOWED_COMMANDS = %w(ls deploy destroy teardown deploy_all).freeze

  def self.run(args)
    options = Options.parse(args)
    options.commands.each do |command|
      case command
      when 'ls' # show all (environments) and stacks
        Ranch::Cowboy.new(options).ls
      when 'deploy' # deploy/upsert (create or upgrade) stack
        Ranch::Cowboy.new(options).deploy
      when 'destroy' # destroy stack
        Ranch::Cowboy.new(options).destroy
      when 'teardown' # teardown environment
        Ranch::Cowboy.new(options).teardown
      when 'deploy_all' # deploy complete KCI stack to an environment (QA)
        Ranch::Cowboy.new(options).deploy_all
      end
    end
    empty_commands_check(options)
  end

  def self.empty_commands_check(options)
    Logger.log.info('run with --help to get usage information') if options.commands.empty?
  end
end

Rancher::Api.configure do |config|
  config.url = Shia::Config.secrets['RANCHER_URL']
  config.access_key = Shia::Config.secrets['RANCHER_ACCESS_KEY']
  config.secret_key = Shia::Config.secrets['RANCHER_SECRET_KEY']
  config.verbose = false # show api requests
end
