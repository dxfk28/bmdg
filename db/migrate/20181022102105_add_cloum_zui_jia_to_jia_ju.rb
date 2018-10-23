class AddCloumZuiJiaToJiaJu < ActiveRecord::Migration
  def change
  	add_column :jia_ju_piaos, :zui_jia, :integer,comment: '追加'
  end
end
