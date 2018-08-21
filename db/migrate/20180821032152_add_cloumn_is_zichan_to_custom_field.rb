class AddCloumnIsZichanToCustomField < ActiveRecord::Migration
  def change  
  	add_column :custom_fields, :is_zichan, :boolean, default: false,comment: '现场资产信息管理'
  	add_column :custom_fields, :is_changsuo, :boolean, default: false,comment: '场所变更管理'
  	add_column :custom_fields, :is_zaiku, :boolean, default: false,comment: '在库资产信息管理'
  	add_column :custom_fields, :is_feiqi, :boolean, default: false,comment: '资产废弃管理'
  	add_column :custom_fields, :is_huishou, :boolean, default: false,comment: '资产回收管理'
  	add_column :custom_fields, :si_ruku, :boolean, default: false,comment: '资产入库'
  	add_column :custom_fields, :is_zifafang, :boolean, default: false,comment: '治工具发放'
  	add_column :custom_fields, :is_shiwufafang, :boolean, default: false,comment: '一般事务用品发放'
  	add_column :custom_fields, :is_bumenpd, :boolean, default: false,comment: '部门内部盘点'
  	add_column :custom_fields, :zhengze, :string,comment: '正则提示信息'
  end
end
