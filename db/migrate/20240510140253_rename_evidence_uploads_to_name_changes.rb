class RenameEvidenceUploadsToNameChanges < ActiveRecord::Migration[7.1]
  def change
    rename_table :evidence_uploads, :name_changes
  end
end
