class CreateFileImports < ActiveRecord::Migration[7.0]
  def change
    create_table :file_imports do |t|
      t.references :user, foreign_key: true
      t.string :status, default: "pending" # pending, in_progress, completed, failed
      t.integer :total_rows, default: 0
      t.integer :processed_rows, default: 0
      t.integer :success_rows, default: 0
      t.integer :failed_rows, default: 0
      t.timestamps
    end
  end
end
