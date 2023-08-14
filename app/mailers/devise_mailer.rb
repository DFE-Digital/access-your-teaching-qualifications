class DeviseMailer < Devise::Mailer
  DEVISE_NOTIFY_TEMPLATE = "f92c39f3-ec99-4607-a16b-5a0eeb4ef7a3".freeze

  def devise_mail(record, action, opts = {}, &_block)
    initialize_from_record(record)
    view_mail(DEVISE_NOTIFY_TEMPLATE, headers_for(action, opts))
  end
end
