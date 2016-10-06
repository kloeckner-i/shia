require 'pathname'

# stacks are still named environments in the v1 API
module Shia
  module Ranch
    class StackManager
      include Helpers::ActionHelpers

      attr_reader :name

      def initialize(repo:)
        @repo = repo
        @api = ::Rancher::Api::Environment
        Logger.log.info "[#{@repo.name}] initialized"
      end

      def upsert
        case state
        when :active
          upgrade
        when :removed, :offline
          create
        else
          raise RancherModelError, "can't upsert, state is currently: '#{state}'"
        end
      end

      def create
        data = {
          name: @repo.name,
          dockerCompose: @repo.docker_compose,
          rancherCompose: @repo.rancher_compose,
          description: @repo.description,
          environment: @repo.environment,
          startOnCreate: true,
          outputs: {}
        }
        @api.create(data)
        stack.wait_for_state(:active)
        Logger.log.info "[#{@repo.name}] stack create successful"
      end

      def upgrade
        if state.eql?(:active)
          update_stack
          upgrade_stack
        end
        finish_upgrade(stack) if state.eql?(:upgraded)
      end

      def destroy
        return if state.eql?(:offline) || state.eql?(:removed)
        stack.destroy
        Logger.log.info "[#{@repo.name}] stack removed successful"
      end

      def teardown
        @api.all.each do |stack|
          stack.destroy
          stack.wait_for_state('removed')
        end
      end

      def part_of_test_setup?
        return false if state.eql?(:offline)
        stack.environment['SINGLE_DEPLOY'].eql?('true')
      end

      private

      def update_stack
        stack.description = @repo.description
        stack.save
      end

      def upgrade_stack
        data = {
          dockerCompose: @repo.docker_compose,
          rancherCompose: @repo.rancher_compose,
          environment: @repo.environment
        }
        # TODO: why is the rancher-compose.yml not upgraded?
        # https://github.com/rancher/rancher/issues/5631
        stack.run(:upgrade, data: data)
        stack.wait_for_state(:upgraded)
      end

      def state
        stack ? stack.state.to_sym : :offline
      end

      def stack
        @_stack ||= @api.where(name: @repo.name).first
      end
    end
  end
end
