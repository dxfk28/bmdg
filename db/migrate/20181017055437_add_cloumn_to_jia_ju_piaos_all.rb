class AddCloumnToJiaJuPiaosAll < ActiveRecord::Migration
  def change
  	add_column :jia_ju_piaos, :sqsl, :integer,comment: '申请数量'
  	add_column :jia_ju_piaos, :jjsycs, :string,comment: '夹具使用场所'
  	add_column :jia_ju_piaos, :shu_hao, :string,comment: '关联标准书管理编号及整理编号'
  	add_column :jia_ju_piaos, :sqr, :datetime,comment: '申请日'
  	add_column :jia_ju_piaos, :sqbm, :string,comment: '申请部门'
  	add_column :jia_ju_piaos, :sqbm_dd, :integer,comment: '申请部门_担当'
  	add_column :jia_ju_piaos, :sqbm_qr, :integer,comment: '申请部门_确认'
  	add_column :jia_ju_piaos, :sqbm_cr, :integer,comment: '申请部门_承认'
  	add_column :jia_ju_piaos, :xin_she, :integer,comment: '新设'
  	add_column :jia_ju_piaos, :zhui_jia_cl, :string,comment: '追加_产量增加'
  	add_column :jia_ju_piaos, :zhui_jia_xtz, :string,comment: '追加_现体制'
  	add_column :jia_ju_piaos, :zhui_jia_xin_ti_zhi, :string,comment: '追加_新体制'
  	add_column :jia_ju_piaos, :zhui_jia_kssj, :datetime,comment: '追加_开始时间'
  	add_column :jia_ju_piaos, :zhui_jia_xysl, :integer,comment: '追加_现有数量'
  	add_column :jia_ju_piaos, :zhui_jia_zdnl, :string,comment: '追加_最大能力'
  	add_column :jia_ju_piaos, :zhui_jia_sqzjsl, :integer,comment: '追加_申请追加数量'
  	add_column :jia_ju_piaos, :zhui_jia_qt, :text,comment: '追加_其它'
  	add_column :jia_ju_piaos, :sm_jss, :text,comment: '说明或计算式'
  	add_column :jia_ju_piaos, :xi_wang_na_qi, :datetime,comment: '希望纳期'
  	add_column :jia_ju_piaos, :shang_si_yi_jian, :text,comment: '上司意见'
  	add_column :jia_ju_piaos, :pei_bu_xian, :string,comment: '配部先'
  	add_column :jia_ju_piaos, :bu, :string,comment: '部'
  	add_column :jia_ju_piaos, :guan_li_bu_men, :string,comment: '管理部门'
  	add_column :jia_ju_piaos, :shou_li_ri_qi, :datetime,comment: '受理日期'
  	add_column :jia_ju_piaos, :fa_xing_hao, :string,comment: '发行NO'
  	add_column :jia_ju_piaos, :gl_dd, :integer,comment: '管理部门_担当'
  	add_column :jia_ju_piaos, :gl_qr, :integer,comment: '管理部门_确认'
  	add_column :jia_ju_piaos, :gl_cr, :integer,comment: '管理部门_承认'
  	add_column :jia_ju_piaos, :ny_zhui_jia, :integer,comment: '是否按申请内容追加'
  	add_column :jia_ju_piaos, :bn_reason, :text,comment: '不按申请内容追加时,理由记入'
  end
end

