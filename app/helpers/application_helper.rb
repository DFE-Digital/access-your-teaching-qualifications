module ApplicationHelper
  def current_namespace
    request.path.split("/").second
  end

  def navigation
    govuk_header(service_name: t("service.name")) do |header|
      if current_namespace == "qualifications"
        if current_user
          header.with_navigation_item(
            active: current_page?(main_app.qualifications_identity_user_path),
            href: main_app.qualifications_identity_user_path,
            text: "Account"
          )
          header.with_navigation_item(href: main_app.qualifications_sign_out_path, text: "Sign out")
        end
      else
        if current_staff
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
          header.with_navigation_item(
            active: request.path.start_with?("/support/staff"),
            text: "Staff",
            href: main_app.support_interface_staff_index_path
          )
          if FeatureFlags::FeatureFlag.active?(:manage_roles)
            header.with_navigation_item(
              active: request.path.start_with?("/support/roles"),
              text: "Check role codes",
              href: main_app.support_interface_roles_path

            )
          end
          header.with_navigation_item(href: main_app.check_records_sign_out_path, text: "Sign out")
        end
        if current_staff || current_dsi_user
          header.with_navigation_item(
            href: main_app.check_records_dsi_sign_out_path(id_token_hint: session[:id_token]),
            text: "Sign out"
          )
        end
      end
    end
  end
end
