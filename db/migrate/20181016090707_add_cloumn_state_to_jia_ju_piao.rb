class AddCloumnStateToJiaJuPiao < ActiveRecord::Migration
  def change
  	add_column :jia_ju_piaos, :state, :integer,comment: '状态'
  end
end
