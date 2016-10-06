module Shia
  class Environment
    class NoEnvGivenError < StandardError; end
    class ProductionEnvError < StandardError; end
    class WrongEnvOptionsError < StandardError; end

    attr_reader :name, :production

    def initialize(options:)
      check_options(options)
      @name = options.environment if options.environment
      @name = name_from_branch(options.branch) if options.branch
      Logger.log.info "Environment set to: #{@name}"
      @production = 'production'
    end

    def not_set?
      @name.blank?
    end

    def production?
      @name.eql?(@production)
    end

    def check
      return if @name.present?
      Logger.log.info 'If specifying a branch use @environment in the branch name like: feature/.../@test-env'
      raise NoEnvGivenError, 'You need to either set an environment using "-e" or a branch using "-b"!'
    end

    def production_alert
      return unless production?
      raise ProductionEnvError, 'This action is not allowed in the production environment!'
    end

    private

    def check_options(options)
      return unless options.branch && options.environment
      raise WrongEnvOptionsError, 'Only use the "-e" or "-b" option, but not both!'
    end

    def name_from_branch(branch)
      return nil if branch.blank? || !branch.include?('@')
      branch.split('/').select { |s| s.start_with?('@') }.first.delete('@')
    end
  end
end
