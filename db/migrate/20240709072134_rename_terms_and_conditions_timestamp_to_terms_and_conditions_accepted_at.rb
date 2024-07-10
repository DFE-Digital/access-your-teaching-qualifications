class RenameTermsAndConditionsTimestampToTermsAndConditionsAcceptedAt < ActiveRecord::Migration[7.1]
  def change
    rename_column :dsi_users, :terms_and_conditions_timestamp, :terms_and_conditions_accepted_at
  end
end
