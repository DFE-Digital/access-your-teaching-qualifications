module ApplicationHelper
  include Pagy::Frontend

  def current_namespace
    request.path.split("/").second
  end

  # TODO: refactor Support navigation into a component
  def support_navigation
    govuk_service_navigation(
      service_name: "AYTQ / CTR Support",
      navigation_items: begin
        items = []

        if current_dsi_user.internal?
          items << {
            current: current_page?(main_app.support_interface_feature_flags_path),
            href: main_app.support_interface_feature_flags_path,
            text: "Features"
          }
          items << {
            current: request.path.start_with?("/support/feedback"),
            text: "Feedback",
            href: main_app.support_interface_feedback_index_path
          }
          if FeatureFlags::FeatureFlag.active?(:manage_roles)
            items << {
              current: request.path.start_with?("/support/roles"),
              text: "Check role codes",
              href: main_app.support_interface_roles_path
            }
          end
        end
        if current_dsi_user
          items << {
            href: main_app.check_records_dsi_sign_out_path(id_token_hint: session[:id_token]),
            text: "Sign out"
          }
        end

        items
      end
    )
  end
end
