class PollsController < ApplicationController
  # unloadable
  layout "index"
  before_filter :find_project, :except => [:search_index]
  before_filter :check_if_login_required, :except => [:index,:pandian_tubiao]
  before_filter :build_new_issue_from_params, :only => [:point_check_new, :point_check_create]
  before_filter :find_issues, :only => [:bulk_edit, :bulk_update, :destroy]

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
  helper :search

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
    redirect_to home_path()
  end

  def index
    @issue = Issue.find_by(subject:params[:issue_code])
    if @issue.present?
      @journals = @issue.journals.includes(:user, :details).
                      references(:user, :details).
                      reorder(:created_on, :id).to_a
      @journals.each_with_index {|j,i| j.indice = i+1}
      @journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
      Journal.preload_journals_details_custom_fields(@journals)
      @journals.select! {|journal| journal.notes? || journal.visible_details.any?}
      @journals.reverse! if User.current.wants_comments_in_reverse_order?
      render partial: "jilu", layout: false
    else
      render partial: "jilu", layout: false
    end
  end

  def vote
  end

  def show
    @issue = Issue.find_by(id:params[:id])
    @journals = @issue.journals.includes(:user, :details).
                    references(:user, :details).
                    reorder(:created_on, :id).to_a
    @journals.each_with_index {|j,i| j.indice = i+1}
    @journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
    Journal.preload_journals_details_custom_fields(@journals)
    @journals.select! {|journal| journal.notes? || journal.visible_details.any?}
    @journals.reverse! if User.current.wants_comments_in_reverse_order?

    @changesets = @issue.changesets.visible.preload(:repository, :user).to_a
    @changesets.reverse! if User.current.wants_comments_in_reverse_order?

    @relations = @issue.relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    @priorities = IssuePriority.active
    @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)
    @relation = IssueRelation.new
    retrieve_previous_and_next_issue_ids
  end

  def retrieve_previous_and_next_issue_ids
    retrieve_query_from_session
    if @query
      sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
      sort_update(@query.sortable_columns, 'issues_index_sort')
      limit = 500
      issue_ids = @query.issue_ids(:order => sort_clause, :limit => (limit + 1), :include => [:assigned_to, :tracker, :priority, :category, :fixed_version])
      if (idx = issue_ids.index(@issue.id)) && idx < limit
        if issue_ids.size < 500
          @issue_position = idx + 1
          @issue_count = issue_ids.size
        end
        @prev_issue_id = issue_ids[idx - 1] if idx > 0
        @next_issue_id = issue_ids[idx + 1] if idx < (issue_ids.size - 1)
      end
    end
  end

  def point_check_create
    unless User.current.allowed_to?(:add_issues, @issue.project, :global => true)
      raise ::Unauthorized
    end
    call_hook(:controller_issues_new_before_save, { :params => params, :issue => @issue })
    @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
    if @issue.save
      call_hook(:controller_issues_new_after_save, { :params => params, :issue => @issue})
      respond_to do |format|
        format.html {
          render_attachment_warning_if_needed(@issue)
          flash[:notice] = l(:notice_issue_successful_create, :id => view_context.link_to("##{@issue.id}", poll_path(@issue,project_id:@issue.project_id), :title => @issue.subject))
          redirect_after_create
        }
        format.api  { render :action => 'show', :status => :created, :location => issue_url(@issue) }
      end
      return
    else
      respond_to do |format|
        format.html {
          if @issue.project.nil?
            render_error :status => 422
          else
            render :action => 'new'
          end
        }
        format.api  { render_validation_errors(@issue) }
      end
    end
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

  def destroy
    issue = Issue.find_by(id:params[:id])
    if issue.destroy
      redirect_to point_check_index_polls_path(project_id:@project.id,tracker_id:issue.tracker_id,set_filter:1)
    else
      flash[:error] = "无法删除，请稍后重试 "
      redirect_to poll_path(issue,project_id:@project.id)
    end
  end

  def point_check_edit
    @issue = Issue.find_by(id:params[:id])
  end

  def edit
    @issue = Issue.find_by(id:params[:id])
    @project = @issue.project
    update_issue_from_params
    @relations = @issue.relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
    @relation = IssueRelation.new
  end

  def update
    @issue = Issue.find(params[:id])
    @project = @issue.project
    return unless update_issue_from_params
    @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
    saved = false
    begin
      saved = save_issue_with_child_records
    rescue ActiveRecord::StaleObjectError
      @conflict = true
      if params[:last_journal_id]
        @conflict_journals = @issue.journals_after(params[:last_journal_id]).to_a
        @conflict_journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
      end
    end

    if saved
      render_attachment_warning_if_needed(@issue)
      flash[:notice] = l(:notice_successful_update) unless @issue.current_journal.new_record?

      respond_to do |format|
        format.html { redirect_back_or_default poll_path(@issue,project_id:@issue.project_id) }
        format.api  { render_api_ok }
      end
    else
      flash[:notice] = @issue.errors.full_messages.join(',')
      redirect_to edit_poll_path(@issue,project_id:@issue.project_id)
    end
  end

  # Saves @issue and a time_entry from the parameters
  def save_issue_with_child_records
    Issue.transaction do
      if params[:time_entry] && (params[:time_entry][:hours].present? || params[:time_entry][:comments].present?) && User.current.allowed_to?(:log_time, @issue.project)
        time_entry = @time_entry || TimeEntry.new
        time_entry.project = @issue.project
        time_entry.issue = @issue
        time_entry.user = User.current
        time_entry.spent_on = User.current.today
        time_entry.attributes = params[:time_entry]
        @issue.time_entries << time_entry
      end

      call_hook(:controller_issues_edit_before_save, { :params => params, :issue => @issue, :time_entry => time_entry, :journal => @issue.current_journal})
      if @issue.save
        call_hook(:controller_issues_edit_after_save, { :params => params, :issue => @issue, :time_entry => time_entry, :journal => @issue.current_journal})
      else
        raise ActiveRecord::Rollback
      end
    end
  end
  def update_issue_from_params
    @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)
    if params[:time_entry]
      @time_entry.safe_attributes = params[:time_entry]
    end

    @issue.init_journal(User.current)

    issue_attributes = params[:issue]
    if issue_attributes && params[:conflict_resolution]
      case params[:conflict_resolution]
      when 'overwrite'
        issue_attributes = issue_attributes.dup
        issue_attributes.delete(:lock_version)
      when 'add_notes'
        issue_attributes = issue_attributes.slice(:notes, :private_notes)
      when 'cancel'
        return false
      end
    end
    @issue.safe_attributes = issue_attributes
    @priorities = IssuePriority.active
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    true
  end

  def search_index
    find_optional_project
    @question = params[:q] || ""
    @question.strip!
    @all_words = params[:all_words] ? params[:all_words].present? : true
    @titles_only = params[:titles_only] ? params[:titles_only].present? : false
    @search_attachments = params[:attachments].presence || '0'
    @open_issues = params[:open_issues] ? params[:open_issues].present? : false

    # quick jump to an issue
    if (m = @question.match(/^#?(\d+)$/)) && (issue = Issue.visible.find_by_id(m[1].to_i))
      redirect_to poll_path(issue,project_id:issue.project_id)
      return
    end

    projects_to_search =
      case params[:scope]
      when 'all'
        nil
      when 'my_projects'
        User.current.projects
      when 'subprojects'
        @project ? (@project.self_and_descendants.active.to_a) : nil
      else
        @project
      end

    @object_types = Redmine::Search.available_search_types.dup
    if projects_to_search.is_a? Project
      # don't search projects
      @object_types.delete('projects')
      # only show what the user is allowed to view
      @object_types = @object_types.select {|o| User.current.allowed_to?("view_#{o}".to_sym, projects_to_search)}
    end

    @scope = @object_types.select {|t| params[t]}
    @scope = @object_types if @scope.empty?

    fetcher = Redmine::Search::Fetcher.new(
      @question, User.current, @scope, projects_to_search,
      :all_words => @all_words, :titles_only => @titles_only, :attachments => @search_attachments, :open_issues => @open_issues,
      :cache => params[:page].present?
    )

    if fetcher.tokens.present?
      @result_count = fetcher.result_count
      @result_count_by_type = fetcher.result_count_by_type
      @tokens = fetcher.tokens

      per_page = Setting.search_results_per_page.to_i
      per_page = 10 if per_page == 0
      @result_pages = Paginator.new @result_count, per_page, params['page']
      @results = fetcher.results(@result_pages.offset, @result_pages.per_page)
    else
      @question = ""
    end
    render :layout => false if request.xhr?
  end

  # Bulk edit/copy a set of issues
  def bulk_edit
    @issues.sort!
    @copy = params[:copy].present?
    @notes = params[:notes]

    if @copy
      unless User.current.allowed_to?(:copy_issues, @projects)
        raise ::Unauthorized
      end
    end

    @allowed_projects = Issue.allowed_target_projects
    if params[:issue]
      @target_project = @allowed_projects.detect {|p| p.id.to_s == params[:issue][:project_id].to_s}
      if @target_project
        target_projects = [@target_project]
      end
    end
    target_projects ||= @projects

    if @copy
      # Copied issues will get their default statuses
      @available_statuses = []
    else
      @available_statuses = @issues.map(&:new_statuses_allowed_to).reduce(:&)
    end
    @custom_fields = @issues.map{|i|i.editable_custom_fields}.reduce(:&)
    @assignables = target_projects.map(&:assignable_users).reduce(:&)
    @trackers = target_projects.map(&:trackers).reduce(:&)
    @versions = target_projects.map {|p| p.shared_versions.open}.reduce(:&)
    @categories = target_projects.map {|p| p.issue_categories}.reduce(:&)
    if @copy
      @attachments_present = @issues.detect {|i| i.attachments.any?}.present?
      @subtasks_present = @issues.detect {|i| !i.leaf?}.present?
    end

    @safe_attributes = @issues.map(&:safe_attribute_names).reduce(:&)

    @issue_params = params[:issue] || {}
    @issue_params[:custom_field_values] ||= {}
  end

  def bulk_update
    @issues.sort!
    @copy = params[:copy].present?

    attributes = parse_params_for_bulk_issue_attributes(params)
    copy_subtasks = (params[:copy_subtasks] == '1')
    copy_attachments = (params[:copy_attachments] == '1')

    if @copy
      unless User.current.allowed_to?(:copy_issues, @projects)
        raise ::Unauthorized
      end
      target_projects = @projects
      if attributes['project_id'].present?
        target_projects = Project.where(:id => attributes['project_id']).to_a
      end
      unless User.current.allowed_to?(:add_issues, target_projects)
        raise ::Unauthorized
      end
    end

    unsaved_issues = []
    saved_issues = []

    if @copy && copy_subtasks
      # Descendant issues will be copied with the parent task
      # Don't copy them twice
      @issues.reject! {|issue| @issues.detect {|other| issue.is_descendant_of?(other)}}
    end

    @issues.each do |orig_issue|
      orig_issue.reload
      if @copy
        issue = orig_issue.copy({},
          :attachments => copy_attachments,
          :subtasks => copy_subtasks,
          :link => link_copy?(params[:link_copy])
        )
      else
        issue = orig_issue
      end
      journal = issue.init_journal(User.current, params[:notes])
      issue.safe_attributes = attributes
      call_hook(:controller_issues_bulk_edit_before_save, { :params => params, :issue => issue })
      if issue.save
        saved_issues << issue
      else
        unsaved_issues << orig_issue
      end
    end
    if unsaved_issues.empty?
      flash[:notice] = l(:notice_successful_update) unless saved_issues.empty?
      if params[:follow]
        if @issues.size == 1 && saved_issues.size == 1
          redirect_to poll_path(saved_issues.first)
        elsif saved_issues.map(&:project).uniq.size == 1
          redirect_to point_check_index_polls_path(project_id:saved_issues.map(&:project).first.id,set_filter: 1,tracker_id:saved_issues.map(&:tracker).first.id)
        end
      else
        redirect_back_or_default point_check_index_polls_path(project_id:saved_issues.map(&:project).first.id,set_filter: 1,tracker_id:saved_issues.map(&:tracker).first.id) 
      end
    else
      @saved_issues = @issues
      @unsaved_issues = unsaved_issues
      @issues = Issue.visible.where(:id => @unsaved_issues.map(&:id)).to_a
      bulk_edit
      render :action => 'bulk_edit'
    end
  end

  def parse_params_for_bulk_issue_attributes(params)
    attributes = (params[:issue] || {}).reject {|k,v| v.blank?}
    attributes.keys.each {|k| attributes[k] = '' if attributes[k] == 'none'}
    if custom = attributes[:custom_field_values]
      custom.reject! {|k,v| v.blank?}
      custom.keys.each do |k|
        if custom[k].is_a?(Array)
          custom[k] << '' if custom[k].delete('__none__')
        else
          custom[k] = '' if custom[k] == '__none__'
        end
      end
    end
    attributes
  end

  def queries_create
    @project = Project.find(params[:project_id])
    @query = IssueQuery.new
    @query.user = User.current
    @query.project = @project
    update_query_from_params
    if @query.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to point_check_index_polls_path(project_id:@project.id,tracker_id:params[:tracker_id],set_filter:1 ,:query_id => @query)
    else
      render :action => 'queries_new', :layout => !request.xhr?
    end
  end

  def queries_new
    find_optional_project
    @project = Project.find(params[:project_id])
    @query = IssueQuery.new
    @query.user = User.current
    @query.project = @project
    @query.build_from_params(params)
  end

  def queries_edit
    @project = Project.find_by(id:params[:project_id])
    @query = Query.find_by(id:params[:query_id])
  end

  def queries_update
    @query = Query.find_by(id:params[:query_id])
    update_query_from_params
    if @query.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to point_check_index_polls_path(:query_id => @query,project_id:params[:project_id])
    else
      render :action => 'edit'
    end
  end

  def find_optional_project
    @project = Project.find(params[:project_id]) if params[:project_id]
    render_403 unless User.current.allowed_to?(:save_queries, @project, :global => true)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def update_query_from_params
    @query.project = params[:query_is_for_all] ? nil : @project
    @query.build_from_params(params)
    @query.column_names = nil if params[:default_columns]
    @query.sort_criteria = params[:query] && params[:query][:sort_criteria]
    @query.name = params[:query] && params[:query][:name]
    if User.current.allowed_to?(:manage_public_queries, @query.project) || User.current.admin?
      @query.visibility = (params[:query] && params[:query][:visibility]) || IssueQuery::VISIBILITY_PRIVATE
      @query.role_ids = params[:query] && params[:query][:role_ids]
    else
      @query.visibility = IssueQuery::VISIBILITY_PRIVATE
    end
    @query
  end

  def pandian_tubiao
    start_time = params[:start_time].to_date
    end_time = params[:end_time].to_date
    @user = User.find_by(login:params[:user_name])
    name_value = @user.login.to_s + @user.lastname.to_s
    issue_ids = CustomValue.where(value:name_value,custom_field_id: 1402).pluck(:customized_id)
    @issues = Issue.where(id:issue_ids)
    finish_issue_ids = CustomValue.where("customized_id in (?) and custom_field_id = ? and value >= ? and value <= ?",issue_ids,1399,start_time,end_time).pluck(:customized_id)
    @no_issues = @issues.where.not(id:finish_issue_ids)
    respond_to do |format|
      format.api
    end
  end

  def lvli_list
    @issue = Issue.find_by(id:params[:id])
    @journals = @issue.journals.includes(:user, :details).
                    references(:user, :details).
                    reorder(:created_on, :id).to_a
    @journals.each_with_index {|j,i| j.indice = i+1}
    @journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
    Journal.preload_journals_details_custom_fields(@journals)
    @journals.select! {|journal| journal.notes? || journal.visible_details.any?}
    @journals.reverse! if User.current.wants_comments_in_reverse_order?
    @journal_details = JournalDetail.where(id:@journals.map(&:visible_details).flatten.map{|i| i.id},prop_key:1399)
    @journal_details = @journal_details.page(params[:page]).per(20)
  end

  private

  def find_optional_project
    return true unless params[:id]
    @project = Project.find(params[:id])
    check_project_privacy
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  # Used by #new and #create to build a new issue from the params
  # The new issue will be copied from an existing one if copy_from parameter is given
  def build_new_issue_from_params
    @issue = Issue.new
    if params[:copy_from]
      begin
        @issue.init_journal(User.current)
        @copy_from = Issue.visible.find(params[:copy_from])
        unless User.current.allowed_to?(:copy_issues, @copy_from.project)
          raise ::Unauthorized
        end
        @link_copy = link_copy?(params[:link_copy]) || request.get?
        @copy_attachments = params[:copy_attachments].present? || request.get?
        @copy_subtasks = params[:copy_subtasks].present? || request.get?
        @issue.copy_from(@copy_from, :attachments => @copy_attachments, :subtasks => @copy_subtasks, :link => @link_copy)
      rescue ActiveRecord::RecordNotFound
        render_404
        return
      end
    end
    @issue.project = @project
    if request.get?
      @issue.project ||= @issue.allowed_target_projects.first
    end
    @issue.author ||= User.current
    @issue.start_date ||= Date.today if Setting.default_issue_start_date_to_creation_date?

    attrs = (params[:issue] || {}).deep_dup
    if action_name == 'new' && params[:was_default_status] == attrs[:status_id]
      attrs.delete(:status_id)
    end
    if action_name == 'new' && params[:form_update_triggered_by] == 'issue_project_id'
      # Discard submitted version when changing the project on the issue form
      # so we can use the default version for the new project
      attrs.delete(:fixed_version_id)
    end
    @issue.safe_attributes = attrs

    if @issue.project
      @issue.tracker ||= @issue.project.trackers.first
      if @issue.tracker.nil?
        render_error l(:error_no_tracker_in_project)
        return false
      end
      if @issue.status.nil?
        render_error l(:error_no_default_issue_status)
        return false
      end
    end

    @priorities = IssuePriority.active
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
  end

	def find_project
	 @project = Project.find(params[:project_id]) if params[:project_id]
	end
  # Redirects user after a successful issue creation
  def redirect_after_create
    if params[:continue]
      attrs = {:tracker_id => @issue.tracker, :parent_issue_id => @issue.parent_issue_id}.reject {|k,v| v.nil?}
      if params[:project_id]
        return redirect_to point_check_new_polls_path(@issue.project, :issue => attrs,project_id:@issue.project_id)
      else
        attrs.merge! :project_id => @issue.project_id
        return redirect_to new_poll_path(:issue => attrs)
      end
    else
      return redirect_to poll_path(@issue,project_id:@issue.project_id)
    end
  end
end
