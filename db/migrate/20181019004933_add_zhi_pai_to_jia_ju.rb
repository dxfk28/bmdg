class AddZhiPaiToJiaJu < ActiveRecord::Migration
  def change
  	add_column :jia_ju_piaos, :zhi_pai, :integer,comment: '指派给'
  end
end
