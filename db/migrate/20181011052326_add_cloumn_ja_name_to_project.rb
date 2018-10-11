class AddCloumnJaNameToProject < ActiveRecord::Migration
  def change
  	add_column :projects, :ja_name, :string,comment: '日本名称'
  	add_column :projects, :en_name, :string,comment: '英文名称'
  end
end
