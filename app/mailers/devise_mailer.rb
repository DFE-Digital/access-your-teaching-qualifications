class DeviseMailer < Devise::Mailer
  DEVISE_NOTIFY_TEMPLATE = "5e1842e6-d806-49ce-ba19-0483a056e367".freeze

  def devise_mail(record, action, opts = {}, &_block)
    initialize_from_record(record)
    view_mail(DEVISE_NOTIFY_TEMPLATE, headers_for(action, opts))
  end
end
