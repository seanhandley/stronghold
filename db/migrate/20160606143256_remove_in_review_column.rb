class RemoveInReviewColumn < ActiveRecord::Migration
  def change
    remove_column :organizations, :in_review, :boolean
  end
end
