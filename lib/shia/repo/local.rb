module Shia
  module Repo
    class Local < Base
      def initialize
        @group = config.group
        @project = config.project
      end

      private

      def commit_hash
        ENV['CI_BUILD_REF']
      end

      def branch
        ENV['CI_BUILD_REF_NAME']
      end

      def path
        '.'
      end
    end
  end
end
