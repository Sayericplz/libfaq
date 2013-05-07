class CreateFaqs < ActiveRecord::Migration
  def change
    create_table :faqs do |t|
      t.string :keywords
      t.text :question
      t.datetime :questiondate
      t.text :answer
      t.datetime :answerdate
      t.string :checkperson
      t.datetime :checkdate
      t.integer :hit
      t.boolean :enable

      t.timestamps
    end
  end
end
