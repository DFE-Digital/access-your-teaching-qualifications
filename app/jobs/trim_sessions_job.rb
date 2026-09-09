require "rake"

class TrimSessionsJob < ApplicationJob
  def perform
    load_tasks_once
    task = Rake::Task["db:sessions:trim"]
    task.reenable
    task.invoke
  end

  private

  # Sidekiq processes are long-lived and load_tasks appends to tasks that already
  # exist, so calling it on every run would give each task another body.
  def load_tasks_once
    return if Rake::Task.task_defined?("db:sessions:trim")

    Rails.application.load_tasks
  end
end
