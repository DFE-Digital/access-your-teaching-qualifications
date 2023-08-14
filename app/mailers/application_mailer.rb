# frozen_string_literal: true
class ApplicationMailer < Mail::Notify::Mailer
  GENERIC_NOTIFY_TEMPLATE = "d5bddb2d-e560-4de1-a851-5e470bf06c76"

  def notify_email(headers)
    headers = headers.merge(rails_mailer: mailer_name, rails_mail_template: action_name)
    view_mail(GENERIC_NOTIFY_TEMPLATE, headers)
  end
end
