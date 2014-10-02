class CommentsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @comment = current_user.comments.create(params[:comment].permit([:commentable_type, :commentable_id, :body]))
  end

  def destroy
    @comment = current_user.comments.where(id: params[:id]).first
    
    respond_to do |format|
      if @comment.blank?
        format.js { head :unprocessable_entity }
      else
        @comment.destroy
        
        format.js { head :no_content } # 204 No Content
      end
    end
  end
end
