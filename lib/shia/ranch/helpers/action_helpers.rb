module Shia
  module Ranch
    module Helpers
      module ActionHelpers
        def finish_upgrade(entity)
          entity.run(:finishupgrade)
          entity.wait_for_state(:active)
          Logger.log.info "[#{log_name(entity)}] upgrade finished"
        end

        def deactivate(entity)
          entity.run(:deactivate)
          entity.wait_for_state('inactive')
          Logger.log.info "[#{log_name(entity)}] deactivate finished"
        end

        def remove(entity)
          entity.run(:remove)
          entity.wait_for_state('removed')
          Logger.log.info "[#{log_name(entity)}] remove finished"
        end

        def purge(entity)
          entity.run(:purge)
          Logger.log.info "[#{log_name(entity)}] purge finished"
        end

        def log_name(entity)
          "#{entity.type}/#{entity.name}"
        end
      end
    end
  end
end
