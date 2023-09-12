# frozen_string_literal: true

class Staff::InvitationsController < Devise::InvitationsController
  include SupportNamespaceable
  protect_from_forgery prepend: true

  protected

  def invite_resource(&block)
    if !current_inviter.respond_to?(:primary_key)
      resource_class.invite!(invite_params, &block)
    else
      super
    end
  end

  def after_invite_path_for(inviter, invitee)
    invitee.is_a?(Staff) ? support_interface_staff_index_path : super
  end

  def after_accept_path_for(resource)
    resource.is_a?(Staff) ? support_interface_staff_index_path : super
  end
end
