class AddCloumnIsShowToCustomField < ActiveRecord::Migration
  def change
  	add_column :custom_fields, :is_show, :boolean, :default => false
  end
end
