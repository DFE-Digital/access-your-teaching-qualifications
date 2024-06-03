module ApplicationHelper
  def current_namespace
    request.path.split("/").second
  end

  # TODO: refactor Support navigation into a component
  def support_navigation
    govuk_header(service_name: "AYTQ / CTR Support") do |header|
      if current_dsi_user.internal?
        header.with_navigation_item(
          active: current_page?(main_app.support_interface_feature_flags_path),
          href: main_app.support_interface_feature_flags_path,
          text: "Features"
        )
        header.with_navigation_item(
          active: request.path.start_with?("/support/feedback"),
          text: "Feedback",
          href: main_app.support_interface_feedback_index_path
        )
        if FeatureFlags::FeatureFlag.active?(:manage_roles)
          header.with_navigation_item(
            active: request.path.start_with?("/support/roles"),
            text: "Check role codes",
            href: main_app.support_interface_roles_path

          )
        end
      end
      if current_dsi_user
        header.with_navigation_item(
          href: main_app.check_records_dsi_sign_out_path(id_token_hint: session[:id_token]),
          text: "Sign out"
        )
      end
    end
  end
end
