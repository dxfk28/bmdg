class AddCloumnsToJiaJu < ActiveRecord::Migration
  def change
  	remove_column :jia_ju_piaos, :pei_bu_xian
  	remove_column :jia_ju_piaos, :bu
  	add_column :jia_ju_piaos, :pei_bu_xian_1, :string,comment: '配部先_1'
  	add_column :jia_ju_piaos, :pei_bu_xian_2, :string,comment: '配部先_2'
  	add_column :jia_ju_piaos, :pei_bu_xian_3, :string,comment: '配部先_3'
  	add_column :jia_ju_piaos, :pei_bu_xian_4, :string,comment: '配部先_4'
  	add_column :jia_ju_piaos, :pei_bu_xian_5, :string,comment: '配部先_5'
  	add_column :jia_ju_piaos, :bu_1, :integer,comment: '部_1'
  	add_column :jia_ju_piaos, :bu_2, :integer,comment: '部_1'
  	add_column :jia_ju_piaos, :bu_3, :integer,comment: '部_1'
  	add_column :jia_ju_piaos, :bu_4, :integer,comment: '部_1'
  	add_column :jia_ju_piaos, :bu_5, :integer,comment: '部_1'
  end
end
