module Qualifications
  module OneLoginUsers
    class TeachingRecordNamesController < QualificationsInterfaceController
      def edit
        @name_change_form = NameChangeForm.new
      end

      def update
        @name_change_form = NameChangeForm.new(name_change_form_params)
        if @name_change_form.save
          redirect_to qualifications_one_login_user_path, notice: 'Name change was successfully submitted.'
        else
          render :edit
        end
      end

      private

      def name_change_form_params
        params
          .require(:qualifications_one_login_users_name_change_form)
          .permit(:first_name, :middle_name, :last_name, :evidence)
      end
    end
  end
end
