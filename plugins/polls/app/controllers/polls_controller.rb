class PollsController < ApplicationController
  # unloadable
  layout "index"
  before_filter :find_project
  before_filter :check_if_login_required, :except => :index

  helper :journals
  helper :projects
  helper :custom_fields
  helper :issue_relations
  helper :watchers
  helper :attachments
  helper :queries
  include QueriesHelper
  helper :repositories
  helper :sort
  include SortHelper
  helper :timelog
  helper :issues
  helper :polls

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
    retrieve_query
    @tracker = Tracker.find(params[:tracker_id]) if params[:tracker_id].present?
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    @query.sort_criteria = sort_criteria.to_a

    if @query.valid?
      case params[:format]
      when 'csv', 'pdf'
        @limit = Setting.issues_export_limit.to_i
        if params[:columns] == 'all'
          @query.column_names = @query.available_inline_columns.map(&:name)
        end
      when 'atom'
        @limit = Setting.feeds_limit.to_i
      when 'xml', 'json'
        @offset, @limit = api_offset_and_limit
        @query.column_names = %w(author)
      else
        @limit = per_page_option
      end

      @issue_count = @query.issue_count
      @issue_pages = Paginator.new @issue_count, @limit, params['page']
      @offset ||= @issue_pages.offset
      @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                              :order => sort_clause,
                              :offset => @offset,
                              :limit => @limit)
      @issue_count_by_group = @query.issue_count_by_group

      respond_to do |format|
        format.html { render :template => 'polls/point_check_index', :layout => !request.xhr? }
        format.api  {
          Issue.load_visible_relations(@issues) if include_in_api_response?('relations')
        }
        format.atom { render_feed(@issues, :title => "#{@project || Setting.app_title}: #{l(:label_issue_plural)}") }
        format.csv  { send_data(query_to_csv(@issues, @query, params[:csv]), :type => 'text/csv; header=present', :filename => 'issues.csv') }
        format.pdf  { send_file_headers! :type => 'application/pdf', :filename => 'issues.pdf' }
      end
    else
      respond_to do |format|
        format.html { render(:template => 'polls/point_check_index', :layout => !request.xhr?) }
        format.any(:atom, :csv, :pdf) { render(:nothing => true) }
        format.api { render_validation_errors(@query) }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def point_check_list
    @project = Project.find(params[:project_id])
    cond = @project.project_condition(Setting.display_subprojects_issues?)
    @trackers = @project.rolled_up_trackers
    @open_issues_by_tracker = Issue.visible.open.where(cond).group(:tracker).count
    @total_issues_by_tracker = Issue.visible.where(cond).group(:tracker).count
  end

  def create
  end

  private
	def find_project
	 @project = Project.find(params[:project_id]) if params[:project_id]
	end

end
