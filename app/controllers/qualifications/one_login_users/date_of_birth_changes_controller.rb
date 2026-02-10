module Qualifications
  module OneLoginUsers
    class DateOfBirthChangesController < QualificationsInterfaceController
      DOB_CONVERSION = {
        "date_of_birth(3i)" => "day",
        "date_of_birth(2i)" => "month",
        "date_of_birth(1i)" => "year",
      }.freeze

      before_action :redirect_to_root_unless_one_login_active
      before_action :redirect_if_change_pending, except: [:submitted]

      def new
        @date_of_birth_change_form = DateOfBirthChangeForm.new
      end

      def create
        @date_of_birth_change_form = DateOfBirthChangeForm.new(date_of_birth_change_form_params)
        date_of_birth_change = @date_of_birth_change_form.save

        if date_of_birth_change
          redirect_to qualifications_one_login_user_date_of_birth_change_path(date_of_birth_change)
        else
          render :new
        end
      end

      def edit
        @date_of_birth_change = current_user.date_of_birth_changes.find(params[:id])
        @date_of_birth_change_form = DateOfBirthChangeForm.initialize_with(date_of_birth_change: @date_of_birth_change)
      end

      def update
        @date_of_birth_change = current_user.date_of_birth_changes.find(params[:id])
        @date_of_birth_change_form = DateOfBirthChangeForm.new(date_of_birth_change_form_params)
        if @date_of_birth_change_form.update(@date_of_birth_change)
          redirect_to qualifications_one_login_user_date_of_birth_change_path(@date_of_birth_change)
        else
          render :edit
        end
      end

      def show
        @date_of_birth_change = current_user.date_of_birth_changes.find(params[:id])
      end

      def confirm
        @date_of_birth_change = current_user.date_of_birth_changes.find(params[:id])
        reference_number = qualifications_api_client.send_date_of_birth_change(
          date_of_birth_change: @date_of_birth_change
        )
        @date_of_birth_change.update!(reference_number:)
        @date_of_birth_change.malware_scan

        redirect_to submitted_qualifications_one_login_user_date_of_birth_change_path(@date_of_birth_change)
      end

      def submitted
        @date_of_birth_change = current_user.date_of_birth_changes.find(params[:id])
      end

      private

      def date_of_birth_change_form_params
        params
          .require(:qualifications_one_login_users_date_of_birth_change_form)
          .permit(:evidence, *DOB_CONVERSION.keys)
          .merge(user: current_user)
          .transform_keys do |key|
            DOB_CONVERSION.keys.include?(key) ? DOB_CONVERSION[key] : key
          end
      end

      def qualifications_api_client
        @qualifications_api_client ||= QualificationsApi::Client.new(token: current_session.user_token)
      end

      def redirect_if_change_pending
        teacher = qualifications_api_client.teacher
        if teacher.pending_date_of_birth_change?
          flash[:warning] =
            "We're reviewing your date of birth change request. \
             Wait until your details have been updated before making another request."
          redirect_to qualifications_one_login_user_path
        end
      end
    end
  end
end
