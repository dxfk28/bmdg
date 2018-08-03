class AddCloumnToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :is_mobile, :boolean, default: true,comment: '是否移动可用'
    add_column :custom_fields, :is_check, :boolean, default: true,comment: '是否盘点可用'
    add_column :custom_fields, :is_pc, :boolean, default: true,comment: '是否web可用'
  end
end
