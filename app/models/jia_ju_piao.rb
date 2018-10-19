class JiaJuPiao < ActiveRecord::Base


  acts_as_attachable :after_add => :attachment_added, :after_remove => :attachment_removed
  acts_as_customizable
  acts_as_watchable
  belongs_to :sqbm_cr_user, class_name:"User",:foreign_key => :sqbm_cr
  belongs_to :sqbm_qr_user, class_name:"User",:foreign_key => :sqbm_qr
  belongs_to :sqbm_dd_user, class_name:"User",:foreign_key => :sqbm_dd
  belongs_to :gl_cr_user, class_name:"User",:foreign_key => :gl_cr
  belongs_to :gl_qr_user, class_name:"User",:foreign_key => :gl_qr
  belongs_to :gl_dd_user, class_name:"User",:foreign_key => :gl_dd
  belongs_to :issue, :dependent => :destroy

  STATUS = { 1 => "审核中",  2 => "已废弃",  3 => "使用中", 4 => '未通过', 5 => '仓库担当修改'}
  XIN_SHE = { 1 => "新增作业",  2 => "品质对应",  3 => "作业改进", 4 => '产量增加', 4 => '其他' }
  NY = { 1 => "是",  2 => "否" }
  # Callback on file attachment
  def attachment_added(attachment)
    if current_journal && !attachment.new_record?
      current_journal.journalize_attachment(attachment, :added)
    end
  end

  # Callback on attachment deletion
  def attachment_removed(attachment)
    if current_journal && !attachment.new_record?
      current_journal.journalize_attachment(attachment, :removed)
      current_journal.save
    end
  end

  # Returns the current journal or nil if it's not initialized
  def current_journal
    @current_journal
  end

end
