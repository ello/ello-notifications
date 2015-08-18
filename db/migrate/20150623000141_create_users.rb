class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :notification_count, default: 0

      t.timestamps
    end
  end
end
