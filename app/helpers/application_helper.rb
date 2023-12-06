module ApplicationHelper
  def current_namespace
    request.path.split("/").second
  end

  def navigation
    govuk_header(service_name: t("service.name")) do |header|
      case current_namespace
      when "support"
        if current_staff
          header.with_navigation_item(
            active: current_page?(main_app.support_interface_feature_flags_path),
            href: main_app.support_interface_feature_flags_path,
            text: "Features"
          )
          header.with_navigation_item(
            active: request.path.start_with?("/support/staff"),
            text: "Staff",
            href: main_app.support_interface_staff_index_path
          )
          header.with_navigation_item(href: main_app.support_interface_sign_out_path, text: "Sign out")
        end
      when "qualifications"
        if current_user
          header.with_navigation_item(
            active: current_page?(main_app.qualifications_identity_user_path),
            href: main_app.qualifications_identity_user_path,
            text: "Account"
          )
          header.with_navigation_item(href: main_app.qualifications_sign_out_path, text: "Sign out")
        end
      end
    end
  end
end
