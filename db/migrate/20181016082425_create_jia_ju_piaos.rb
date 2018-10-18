class CreateJiaJuPiaos < ActiveRecord::Migration
  def change
    create_table :jia_ju_piaos do |t|
      t.string :name,comment: '夹具名称'
      t.string :fan_hao,comment: '夹具番号'

      t.timestamps null: false
    end
  end
end
