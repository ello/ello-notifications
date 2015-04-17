class CreateSnsApplications < ActiveRecord::Migration
  def change
    create_table :sns_applications do |t|
      t.string :bundle_identifier
      t.string :application_arn
      t.string :platform

      t.timestamps
    end
  end
end
