class CreateEvidenceUploads < ActiveRecord::Migration[7.1]
  def change
    create_table :evidence_uploads do |t|
      t.belongs_to :user

      t.timestamps
    end
  end
end
