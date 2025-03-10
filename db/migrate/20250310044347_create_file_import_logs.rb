class CreateFileImportLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :file_import_logs do |t|
      t.references :file_import, null: false, foreign_key: true # Associates with file_imports table
      t.integer :row_number
      t.string :status, null: false, default: "pending" # Allowed values: pending, success, failed
      t.text :message

      t.timestamps # Adds created_at and updated_at
    end

    add_index :file_import_logs, :status # Index for filtering by status
  end
end