class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.references :faq
      t.date :thedate
      t.integer :count

      t.timestamps
    end
    add_index :records, :faq_id
  end
end
