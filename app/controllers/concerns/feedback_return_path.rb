# frozen_string_literal: true

# The feedback form's Back link returns the user to the page they left. A
# referrer-based link loops back to the form once a submission fails
# validation, so the origin travels with the request as `return_to` instead.
module FeedbackReturnPath
  extend ActiveSupport::Concern

  included { helper_method :feedback_return_path }

  def feedback_return_path
    @feedback_return_path ||= build_feedback_return_path
  end

  private

  def build_feedback_return_path
    return_to = url_from(params[:return_to]) # nil for another host, so this can't redirect off-site
    return feedback_fallback_path if return_to.blank?
    return feedback_fallback_path if URI(return_to).path == request.path # Back would reopen the form

    return_to
  end
end
