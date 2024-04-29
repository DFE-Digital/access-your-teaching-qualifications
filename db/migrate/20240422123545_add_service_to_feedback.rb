class AddServiceToFeedback < ActiveRecord::Migration[7.1]
  def change
    change_table :feedbacks  do |f|
      f.column :service, :string, default: :check, null: false
    end
    change_column_default :feedbacks, :service, from: :check, to: nil
  end
end
