module ApplicationHelper
  def current_namespace
    request.path.split("/").second
  end

  def navigation
    govuk_header(service_name: t("service.name")) do |header|
      case current_namespace
      when "support"
        header.navigation_item(
          active: current_page?(main_app.support_interface_feature_flags_path),
          href: main_app.support_interface_feature_flags_path,
          text: "Features"
        )
      end
    end
  end
end
