class CreatePortfos < ActiveRecord::Migration[7.0]
  def change
    create_table :portfos do |t|
      t.float :profit
      t.integer :user_id

      t.timestamps
    end
    add_index :portfos, :user_id
  end
end
