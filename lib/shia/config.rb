module Shia
  class Config
    class << self
      def secrets
        load_config(secrets_file)
      end

      def stacks
        load_config(File.expand_path('../../../config/stacks.yml', __FILE__))
      end

      def docker_registry
        load_config(File.expand_path('../../../config/docker_registry.yml', __FILE__))
      end

      def google_config
        load_config(File.expand_path('../../../config/google_config.yml', __FILE__))
      end

      def git_config
        load_config(File.expand_path('../../../config/git_config.yml', __FILE__))
      end

      private

      def load_config(filename)
        return {} unless File.exist?(filename)
        YAML.load(File.read(filename))
      end

      def secrets_file
        ENV['SECRETS_FILE'] || '/keys/secrets.yml'
      end
    end
  end
end
