Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new {|ex,_| Honeybadger.notify(ex) }
  config.redis = { :namespace => 'stronghold' }
end

Sidekiq.configure_client do |config|
 config.redis = { :namespace => 'stronghold' }
end

Sidekiq.default_worker_options = {
  unique: :until_and_while_executing,
  unique_args: ->(args) { [ args.first.except('job_id') ] }
}

if ENV["SIDEKIQ_PROFILE"]
  require "objspace"
  ObjectSpace.trace_object_allocations_start
  Sidekiq.logger.info "allocations tracing enabled"

  module Sidekiq
    module Middleware
      module Server
        class Profiler
          # Number of jobs to process before reporting
          JOBS = 100

          class << self
            mattr_accessor :counter
            self.counter = 0

            def synchronize(&block)
              @lock ||= Mutex.new
              @lock.synchronize(&block)
            end
          end

          def call(worker_instance, item, queue)
            begin
              yield
            ensure
              self.class.synchronize do
                self.class.counter += 1

                if self.class.counter % JOBS == 0
                  Sidekiq.logger.info "reporting allocations after #{self.class.counter} jobs"
                  GC.start
                  ObjectSpace.dump_all(output: File.open("heap.json", "w"))
                  Sidekiq.logger.info "heap saved to heap.json"
                end
              end
            end
          end
        end
      end
    end
  end

  Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
      chain.add Sidekiq::Middleware::Server::Profiler
    end
  end
end
