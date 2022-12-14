class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:show, :edit, :update, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :admin_or_correct_user, only: :show
  before_action :set_one_month, only: :show
  
  def index
    if params[:search].present?
      @users = User.where('name LIKE ?', "%#{params[:search]}%").paginate(page: params[:page]) if params[:search].present?
      @h1_title = "検索結果"
    else
      @users = User.paginate(page: params[:page])
      @h1_title = "全ユーザー一覧"
    end
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil, finished_at: nil).count
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "新規登録しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を編集しました。"
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    users = User.all
    ActiveRecord::Base.transaction do
      users.each { |user| user.update_attributes!(basic_info_params) }
    end
    flash[:success] = "全ユーザーの基本情報を更新しました。"
    redirect_to root_url
      
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "全ユーザーの基本情報の更新に失敗しました。"
    render :edit_basic_info
  end
  
  private
    
    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:basic_time, :work_time)
    end
end
