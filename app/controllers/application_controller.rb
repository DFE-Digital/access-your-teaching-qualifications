require "dfe/analytics/filtered_request_event"

class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests
  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  def trigger_request_event
    return unless DfE::Analytics.enabled?

    request_event =
      DfE::Analytics::FilteredRequestEvent
        .new
        .with_type("web_request")
        .with_request_details(request)
        .with_response_details(response)
        .with_request_uuid(RequestLocals.fetch(:dfe_analytics_request_id))
        .with_data(session_id: session[:session_id])

    request_event.with_user(current_user) if respond_to?(:current_user, true)
    request_event.with_namespace(current_namespace) if respond_to?(:current_namespace, true)

    DfE::Analytics::SendEvents.do([request_event.as_json])
  end
end
