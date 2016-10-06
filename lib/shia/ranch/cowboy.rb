module Shia
  module Ranch
    class Cowboy
      def initialize(options)
        @options = options
        @env = Environment.new(options: options)
        @local_repo = Repo::Local.new
      end

      def deploy
        prepare_environment
        @local_repo.check_images
        StackManager.new(repo: @local_repo).upsert
      end

      def deploy_all
        @env.production_alert
        @local_repo.check_images
        prepare_environment
        deploy_remotes(@local_repo)
        StackManager.new(repo: @local_repo).upsert
      end

      def destroy
        return if environment_manager.state.eql?(:offline)
        environment_manager.set
        StackManager.new(repo: @local_repo).destroy
      end

      def teardown
        @env.production_alert
        return if environment_manager.state.eql?(:offline)
        environment_manager.set
        StackManager.new(repo: @local_repo).teardown
        MachineManager.new(env: @env).teardown
        RegistryManager.new(env: @env).teardown
        EnvironmentManager.new(env: @env).teardown
      end

      def ls
        environments.each do |environment|
          puts "\nENVIRONMENT: #{environment.name} -> #{color_state(environment.state)}"
          next unless environment.state.eql?('active')
          environment.environments.each do |stack|
            puts "STACK: #{stack.name} -> #{color_state(stack.state)}"
          end
        end
      end

      private

      def deploy_remotes(local_repo)
        remotes = Repo::Remote.all(ignore: local_repo)
        remotes.each do |repo|
          Logger.log.debug "Checking deploy pre-conditions for: '#{repo.name}'"
          repo.export
          repo.check_images
        end
        remotes.each do |repo|
          stack_manager = StackManager.new(repo: repo)
          next if stack_manager.part_of_test_setup?
          Logger.log.debug "Deploying '#{repo.name}'"
          stack_manager.upsert
        end
      end

      def prepare_environment
        environment_manager.up
        environment_manager.set
        RegistryManager.new(env: @env).up
        MachineManager.new(env: @env).up
      end

      def environment_manager
        @_environment_manager ||= begin
                                    @env.check
                                    EnvironmentManager.new(env: @env)
                                  end
      end

      def environments
        if @env.not_set?
          ::Rancher::Api::Project.all.reject { |e| e.state.eql?('purged') }
        else
          ::Rancher::Api::Project.find_by_name(name: @env.name)
        end
      end

      def color_state(state)
        case state
        when 'active'
          state.green
        when 'activating'
          state.light_yellow
        else
          state.red
        end
      end
    end
  end
end
