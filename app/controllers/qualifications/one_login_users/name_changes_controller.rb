module Qualifications
  module OneLoginUsers
    class NameChangesController < QualificationsInterfaceController
      before_action :redirect_to_root_unless_one_login_enabled
      before_action :redirect_if_change_pending, only: [:create, :update]

      def new
        @name_change_form = NameChangeForm.new
      end

      def create
        @name_change_form = NameChangeForm.new(name_change_form_params)
        name_change = @name_change_form.save

        if name_change
          redirect_to qualifications_one_login_user_name_change_path(name_change)
        else
          render :new
        end
      end

      def edit
        @name_change = current_user.name_changes.find(params[:id])
        @name_change_form = NameChangeForm.initialize_with(name_change: @name_change)
      end

      def update
        @name_change = current_user.name_changes.find(params[:id])
        @name_change_form = NameChangeForm.new(name_change_form_params)
        if @name_change_form.update(@name_change)
          redirect_to qualifications_one_login_user_name_change_path(@name_change)
        else
          render :edit
        end
      end

      def show
        @name_change = current_user.name_changes.find(params[:id])
      end

      def confirm
        @name_change = current_user.name_changes.find(params[:id])
        reference_number = qualifications_api_client.send_name_change(name_change: @name_change)
        @name_change.update!(reference_number:)

        redirect_to submitted_qualifications_one_login_user_name_change_path(@name_change)
      end

      def submitted
        @name_change = current_user.name_changes.find(params[:id])
      end

      private

      def name_change_form_params
        params
          .require(:qualifications_one_login_users_name_change_form)
          .permit(:first_name, :middle_name, :last_name, :evidence)
          .merge(user: current_user)
      end

      def qualifications_api_client
        @qualifications_api_client ||= QualificationsApi::Client.new(token: session[user_token_session_key])
      end

      def redirect_if_change_pending
        teacher = qualifications_api_client.teacher
        if teacher.pending_name_change?
          flash[:warning] =
            "You have a name change request pending. \
          Please wait until that is complete before submitting another."
          redirect_to qualifications_one_login_user_path
        end
      end
    end
  end
end
