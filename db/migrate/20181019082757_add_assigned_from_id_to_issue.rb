class AddAssignedFromIdToIssue < ActiveRecord::Migration
  def change
  	add_column :issues, :assigned_from_id, :integer,comment: '从那指派用户id'
  end
end
