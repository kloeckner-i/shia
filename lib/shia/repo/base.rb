module Shia
  module Repo
    class Base
      attr_reader :group, :project

      def config
        return OpenStruct.new({}) unless File.exist?(config_path)
        OpenStruct.new(YAML.load(File.read(config_path)))
      end

      def name
        rancherize_name(config.name || "#{@group}-#{@project}")
      end

      def docker_compose
        compose = variable_expansion(docker_compose_file)
        make_volume_names_safe(compose)
      end

      def rancher_compose
        variable_expansion(rancher_compose_file)
      end

      def description
        [branch, commit_hash].join(' : ')
      end

      def environment
        {
          BRANCH: branch,
          COMMIT_HASH: commit_hash,
          SINGLE_DEPLOY: is_a?(Local)
        }
      end

      def check_images
        check_registry # if docker_compose_file.include?('IMAGE_NAME')
      end

      # http://imgur.com/iZcUNxH
      def variable_expansion(text)
        text.gsub!(/[^\$]\${([A-Za-z_0-9-]+)}/) do
          var = env(Regexp.last_match[1])
          $&.gsub(/\${[A-Za-z_0-9-]+}/, var)
        end
        text.gsub(/[^\$]\$([A-Za-z_0-9-]+)/) do
          var = env(Regexp.last_match[1])
          $&.gsub(/\$[A-Za-z_0-9-]+/, var)
        end
      end

      def make_volume_names_safe(text)
        compose = YAML.load(text)
        compose.each do |_, config|
          next unless config['volume_driver'].eql?('convoy-nfs')
          config['volumes'] = config['volumes'].map do |volume|
            make_volume_names_safe_for_convoy(volume)
          end
        end.to_h
        compose.to_yaml
      end

      private

      def make_volume_names_safe_for_convoy(volume)
        source, destination = volume.split(':')
        destination ||= source
        source = source.split('/').select(&:present?).join('_')
        prefix = [@group, @project].join('_')
        source = [prefix, source].join('_') unless source.start_with?(prefix)
        "#{source}:#{destination}"
      end

      def rancherize_name(name)
        name.split(/\W|_/).reject(&:blank?).map(&:downcase).join('-')
      end

      def config_path
        [path, 'shia/config.yml'].join('/')
      end

      def docker_compose_file
        File.read([path, 'shia/compose/docker-compose.yml'].join('/'))
      end

      def rancher_compose_file
        File.read([path, 'shia/compose/rancher-compose.yml'].join('/'))
      end

      def env(var)
        val = case var
              when 'IMAGE_NAME'
                "#{registry_url}/#{docker_image_name_with_hash}"
              else
                ENV[var]
              end
        return val if val
        raise UnsupportedEnvVariableFoundError, "Easy now cowboy, can not expand: #{var}"
      end

      def registry_url
        Shia::Config.docker_registry['url']
      end

      def docker_image_name
        "#{@group}/#{@project}"
      end

      def docker_image_name_with_hash
        "#{docker_image_name}:#{commit_hash}"
      end

      def check_registry
        # TODO: not working currently
        # registry = DockerRegistry.connect(registry_url_with_auth)
        # return if registry.tags(docker_image_name)['tags'].include?(commit_hash)
        # raise ImageNotAvailbleAtDockerRegistryError, "docker image: '#{docker_image_name}' not found"
      end
    end
  end
end
