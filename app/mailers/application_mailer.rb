# frozen_string_literal: true
class ApplicationMailer < Mail::Notify::Mailer
  GENERIC_NOTIFY_TEMPLATE = "5e1842e6-d806-49ce-ba19-0483a056e367"

  def notify_email(headers)
    headers =
      headers.merge(rails_mailer: mailer_name, rails_mail_template: action_name)
    view_mail(GENERIC_NOTIFY_TEMPLATE, headers)
  end
end
