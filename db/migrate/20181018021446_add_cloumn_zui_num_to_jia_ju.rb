class AddCloumnZuiNumToJiaJu < ActiveRecord::Migration
  def change
  	add_column :jia_ju_piaos, :zui_num, :integer,comment: '最大数量'
  end
end
