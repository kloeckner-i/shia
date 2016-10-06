require 'shia/repo/base'
require 'shia/repo/local'
require 'shia/repo/remote'

module Shia
  module Repo
    class UnsupportedEnvVariableFoundError < StandardError; end
    class ImageNotAvailbleAtDockerRegistryError < StandardError; end
  end
end
