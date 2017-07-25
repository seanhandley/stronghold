class JanitorJob < ApplicationJob
  queue_as :slow

  def perform(sanity_data)
    Janitor.sweep(sanity_data)
  end
end