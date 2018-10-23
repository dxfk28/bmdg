class JiaJuPiaosController < ApplicationController
  # unloadable
  layout "index"

  before_filter :find_jia_ju_piao, :only => [:show, :edit, :destroy,:update]

  helper :attachments

  def index
    @q = JiaJuPiao.ransack(params[:q])
    @jia_ju_piaos = @q.result.page(params[:page]).per(12)
    @count = @q.result.size
  end

  def new
    @jia_ju_piao = JiaJuPiao.new()
  end

  def moban_new
    @jia_ju_piao = JiaJuPiao.new()
  end

  def create
    @jia_ju_piao = JiaJuPiao.new(jia_ju_piao_params)
    @jia_ju_piao.state = 1
    @jia_ju_piao.save_attachments(params[:attachments] || (params[:jia_ju_piao] && params[:jia_ju_piao][:uploads]))
    @jia_ju_piao.sqbm_dd = User.current.id
    issue = Issue.new(project_id:22,tracker_id:80,assigned_to_id:@jia_ju_piao.zhi_pai)
    issue.subject = @jia_ju_piao.sqbm + Time.now.strftime('%Y%m%d-%H%M').to_s
    issue.priority_id = 2
    issue.author_id = User.current.id
    issue.save
    cv = CustomValue.new(customized_id:issue.id,custom_field_id:1400,value:@jia_ju_piao.name,customized_type:"Issue")
    cv.save
    cv = CustomValue.new(customized_id:issue.id,custom_field_id:384,value:@jia_ju_piao.fan_hao,customized_type:"Issue")
    cv.save
    @jia_ju_piao.issue_id = issue.id
    if @jia_ju_piao.save
     flash[:success] = l(:notice_successful_create)
     redirect_to jia_ju_piaos_path()
    else
      flash[:error] = l(:notice_error_create)
      redirect_to new_jia_ju_piao_path()
    end
  end

  def show

  end

  def edit

  end

  def update
    if @jia_ju_piao.update_attributes(jia_ju_piao_params)
      flash[:success] = l(:notice_successful_update)
      redirect_to jia_ju_piao_path(@jia_ju_piao)
    else
      flash[:success] = l(:notice_error_update)
      redirect_to jia_ju_piao_path(@jia_ju_piao)
    end
  end

  def destroy
    if @jia_ju_piao.destroy
      flash[:success] = l(:notice_successful_delete)
      redirect_to jia_ju_piaos_path()
    else
      flash[:success] = l(:notice_error_delete)
      redirect_to jia_ju_piaos_path()
    end
  end

  private

    def find_jia_ju_piao
      @jia_ju_piao = JiaJuPiao.find_by(id:params[:id])
    end

    def jia_ju_piao_params
      params.require(:jia_ju_piao).permit!
    end
end
