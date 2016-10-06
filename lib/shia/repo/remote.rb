module Shia
  module Repo
    class Remote < Base
      class << self
        def all(ignore:)
          allowed = list.reject do |remote|
            remote[:group].eql?(ignore.group) && remote[:project].eql?(ignore.project)
          end
          allowed.map { |remote| Remote.new(remote) }
        end

        def list
          Shia::Config.stacks.map do |group, projects|
            projects.map do |project|
              {
                group: group,
                project: project
              }
            end
          end.flatten
        end
      end

      def initialize(group:, project:)
        @group = group
        @project = project
      end

      def export
        cmd = "mkdir -p #{path} && cd #{path} && git archive --remote=#{url} master shia | tar xvf -"
        Logger.log.debug "Exporting deploy config for: '#{url}'"
        Logger.log.debug `#{cmd}`
      end

      private

      def commit_hash
        @_commit_hash ||= `git ls-remote #{url} #{branch} | cut -f 1`.strip
      end

      def branch
        'master'
      end

      def path
        [base_path, @group, @project].join('/')
      end

      def base_path
        '/tmp/repos'
      end

      def url
        "git@#{Shia::Config.git_config['url']}:#{@group}/#{@project}.git"
      end
    end
  end
end
