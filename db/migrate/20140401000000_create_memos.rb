class CreateMemos < ActiveRecord::Migration
  def change
    create_table :memos do |t|
      t.string :text, null: false
#      t.string :truncated, null: false
      t.timestamps
    end
  end
end
