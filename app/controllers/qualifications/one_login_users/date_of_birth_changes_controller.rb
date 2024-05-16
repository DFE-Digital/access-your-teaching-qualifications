module Qualifications
  module OneLoginUsers
    class DateOfBirthChangesController < QualificationsInterfaceController
      DOB_CONVERSION = {
        "date_of_birth(3i)" => "day",
        "date_of_birth(2i)" => "month",
        "date_of_birth(1i)" => "year",
      }.freeze

      before_action :redirect_to_root_unless_one_login_enabled

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

      def show
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
    end
  end
end
