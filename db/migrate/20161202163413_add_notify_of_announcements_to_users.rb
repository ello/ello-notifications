class AddNotifyOfAnnouncementsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notify_of_announcements, :boolean, default: true, null: false
  end
end
