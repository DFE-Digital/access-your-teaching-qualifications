class DeviseMailer < Devise::Mailer
  def devise_mail(record, action, opts = {}, &_block)
    initialize_from_record(record)
    view_mail(
      ApplicationMailer::GENERIC_NOTIFY_TEMPLATE,
      headers_for(action, opts)
    )
  end
end
