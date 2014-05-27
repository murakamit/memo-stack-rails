class MemosController < ApplicationController
  protect_from_forgery with: :exception, except: [:create, :destroy]
  respond_to :html, :json

  def index
    sel = [:id, :text, :updated_at]
    ord = "updated_at DESC"
    @memos = Memo.select(sel).order(ord).page params[:page]
    respond_with @memos
  end

  def new
    @memo = Memo.new
  end

  def create
    @memo = Memo.new memo_params
    if @memo.save
      flash[:notice] = "created successfully."
      redirect_to action: :index #, notice: "created successfully."
    else
      @errors = @memo.errors
      render action: :new, status: 400 # Bad Request
    end
  rescue ActionController::ParameterMissing
    redirect_to action: :new
  end

  def show
    id = params[:id]
    @memo = Memo.find id
    respond_with @memo
  rescue ActiveRecord::RecordNotFound
    render text: "invalid id(#{id})", status: 400 # Bad Request
  end

  def destroy
    id = params[:id]
    memo = Memo.find id
    if memo.destroy
      flash[:notice] = "deleted successfully."
      redirect_to action: :index
    else
      @errors = memo.errors
      flash[:error] = "fail to delete memo(##{id})."
      redirect_to action: :show, id: id
    end
  rescue ActiveRecord::RecordNotFound
    render text: "invalid id(#{id})", status: 400 # Bad Request
  end

  # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
  private
  def memo_params
    params.require(:memo).permit(:text)
  end
end
