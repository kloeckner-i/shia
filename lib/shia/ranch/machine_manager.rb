module Shia
  module Ranch
    class MachineManager
      include Helpers::ActionHelpers

      def initialize(env:)
        @env = env
        @machines_per_environment = 1
        @machines_per_environment = 1 if @env.production?
        @api = ::Rancher::Api::Machine
      end

      def up
        return unless machines_needed > 0
        machines_needed.times { create }
      end

      def create
        data = {
          name: machine_name,
          engineInstallUrl: 'https://get.docker.com/',
          digitaloceanConfig: nil,
          engineInsecureRegistry: [],
          engineRegistryMirror: [],
          genericConfig: nil,
          googleConfig: Shia::Config.google_config.merge(tags: tags)
        }
        @api.create(data)
      end

      def teardown
        @api.all.each do |machine|
          machine.hosts.each do |host|
            deactivate(host) if host.state.eql?('active')
            remove(host) if host.state.eql?('inactive')
            purge(host) if host.state.eql?('removed')
          end
        end
      end

      private

      def tags
        [@env.name.downcase, 'rancher', 'docker-machine']
      end

      def machine_name
        ['rancher-node', @env.name.downcase, secure_random].join('-')
      end

      def secure_random
        SecureRandom.hex(3)
      end

      def machines_needed
        available_count = @api.transitioning.count + @api.active.count
        @machines_per_environment - available_count
      end
    end
  end
end
