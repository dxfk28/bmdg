class AddIssueIdToJiaJu < ActiveRecord::Migration
  def change
  	 add_column :jia_ju_piaos, :issue_id, :integer,comment: 'issue外键'
  	add_column :issues, :jia_ju_piao_id, :integer,comment: 'jia_ju_piao外键'
  end
end
