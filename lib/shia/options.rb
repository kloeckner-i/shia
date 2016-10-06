module Shia
  class Options
    class << self
      def parse(args)
        options = OpenStruct.new
        options.commands = commands(args)
        options.verbose = false

        opt_parser = OptionParser.new do |opts|
          opts.banner = 'Usage: shia command [options]'
          opts.separator ''
          opts.separator "Available commands: #{ALLOWED_COMMANDS.join(', ')}"
          help(opts)
          environment(opts, options)
          branch(opts, options)
        end

        opt_parser.parse!(args)
        options
      end

      private

      def help(opts)
        opts.separator ''
        opts.separator 'Options:'
        opts.on('-v', '--verbose', 'Run verbosely') do
          Logger.log.level = ::Logger::DEBUG
        end
        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
        opts.on_tail('--version', 'Show version') do
          puts VERSION
          exit
        end
      end

      def environment(opts, options)
        opts.on('-e', '--environment ENVIRONMENT', 'Rancher environment name') do |environment|
          options.environment = environment
        end
      end

      def branch(opts, options)
        opts.on('-b', '--branch BRANCH', 'Branch to infer rancher environment name from') do |branch|
          options.branch = branch
        end
      end

      def commands(args)
        args.select { |a| ALLOWED_COMMANDS.include?(a) }
      end
    end
  end
end
