module Shia
  module Ranch
    class EnvironmentManager
      include Helpers::ActionHelpers

      def initialize(env:)
        @env = env
        @api = ::Rancher::Api::Project
      end

      def up
        create if state.eql?(:offline)
        add_users
      end

      def set
        environment.reload
        her_api = Rancher::Api.configure do |config|
          config.url = environment.self_url
        end
        %w(Environment Machine Host Registry Registrycredential).each do |model|
          "Rancher::Api::#{model}".constantize.use_api(her_api)
        end
      end

      def teardown
        return if state.eql?(:offline)
        deactivate(environment) if state.eql?(:active)
        destroy if state.eql?(:inactive)
        puts 'environment teardown successful'
      end

      def state
        environment ? environment.state.to_sym : :offline
      end

      private

      def add_users
        production_environment = @api.find_by_name(name: @env.production).first
        production_members = production_environment.class.get(production_environment.links['projectMembers'])
        members = production_members.map do |pm|
          {
            "externalId": pm.externalId,
            "externalIdType": 'rancher_id',
            "projectId": environment.id,
            "role": pm.role
          }
        end
        environment.run(:setmembers, data: { members: members })
      end

      def create
        @api.create(name: @env.name)
        environment.wait_for_state(:active)
      end

      def destroy
        environment.destroy
      rescue => e
        Logger.log.info "TODO: Environment destroy throws an error: '#{e.inspect}'"
      end

      def environment
        @_environment ||= @api.find_by_name(name: @env.name).first
      end
    end
  end
end
