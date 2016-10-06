module Shia
  module Ranch
    class RegistryManager
      include Helpers::ActionHelpers

      def initialize(env:)
        @env = env
        @api = ::Rancher::Api::Registry
        @credentials_api = ::Rancher::Api::Registrycredential
      end

      def up
        if registry
          update
        else
          create
        end
        if credentials
          update_credentials
        else
          create_credentials
        end
      end

      def teardown
        [@api, @credentials_api].each do |api|
          api.all.each do |entity|
            deactivate(entity) if entity.state.eql?('active')
            entity.destroy
          end
        end
      end

      private

      def update
        registry.name = registry_url
        registry.serverAddress = registry_url
        registry.save
      end

      def update_credentials
        credentials.name = registry_user
        credentials.publicValue = registry_user
        credentials.secretValue = registry_password
        credentials.email = registry_email
        credentials.save
      end

      def create
        data = {
          name: registry_url,
          serverAddress: registry_url
        }
        @api.create(data)
      end

      def create_credentials
        data = {
          name: registry_user,
          registryId: registry.id,
          publicValue: registry_user,
          secretValue: registry_password,
          email: registry_email
        }
        @credentials_api.create(data)
      end

      def registry
        @_registry ||= @api.where(name: registry_url).first
      end

      def credentials
        @credentials_api.where(registryId: registry.id).first
      end

      def registry_user
        Shia::Config.secrets['DOCKER_REGISTRY_USER']
      end

      def registry_password
        Shia::Config.secrets['DOCKER_REGISTRY_PASSWORD']
      end

      def registry_email
        Shia::Config.docker_registry['email']
      end

      def registry_url
        Shia::Config.docker_registry['url']
      end
    end
  end
end
