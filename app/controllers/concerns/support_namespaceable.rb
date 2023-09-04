# frozen_string_literal: true

module SupportNamespaceable
  # Differentiate web requests sent to BigQuery via dfe-analytics
  def current_namespace
    "support"
  end
end
