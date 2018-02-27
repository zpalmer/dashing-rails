module Dashing
  class EventsController < ApplicationController
    include ActionController::Live

    def index
      begin
        @redis = Dashing.redis

        response.headers['Content-Type']      = 'text/event-stream'
        response.headers['X-Accel-Buffering'] = 'no'
        response.stream.write latest_events

        loop do
          @redis.with do |redis_connection|
            redis_connection.psubscribe_with_timeout(61, "#{Dashing.config.redis_namespace}.*") do |on|
              on.pmessage do |pattern, event, data|
                response.stream.write("data: #{data}\n\n")
              end
            end
          end
        end
      rescue IOError, ActionController::Live::ClientDisconnected => error
        logger.error(error)
        logger.info "[Dashing][#{Time.now.utc.to_s}] Stream closed"
      ensure
        Dashing.shutdown_redis
        response.stream.close
      end
    end

    def latest_events
      @redis.with do |redis_connection|
        events = redis_connection.hvals("#{Dashing.config.redis_namespace}.latest")
        events.map { |v| "data: #{v}\n\n" }.join
      end
    end
  end
end
