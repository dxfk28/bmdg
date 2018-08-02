class PollsController < ApplicationController
  # unloadable
  layout "index"
  before_filter :find_project
  before_filter :check_if_login_required, :except => :index

  helper :issues
  helper :journals
  helper :custom_fields

  def check_if_login_required
    # no check needed if user is already logged in
    if User.current.logged?
       return true 
    else
      require_login
    end
     # if Setting.login_required?
  end

  def welcome
    render :layout => false
  end

  def index
    @issue = Issue.find_by(id:params[:issue_id])
    @journals = @issue.journals.includes(:user, :details).
                    references(:user, :details).
                    reorder(:created_on, :id).to_a
    @journals.each_with_index {|j,i| j.indice = i+1}
    @journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
    Journal.preload_journals_details_custom_fields(@journals)
    @journals.select! {|journal| journal.notes? || journal.visible_details.any?}
    @journals.reverse! if User.current.wants_comments_in_reverse_order?
    render partial: "jilu", layout: false
  end

  def vote
  end

  def show
  end

  def point_check_create
   
    redirect_to :back
  end

  def point_check_new
    
  end

  def point_check_index
    
  end

  def create
  end

  private
	def find_project
	 @project = Project.find(params[:project_id]) if params[:project_id]
	end

end
