class CommitsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_commit, only: :update

  skip_before_filter :verify_authenticity_token, only: :update


  def check_in
    begin
      text = params[:content]

      tags = text.split
      tags.delete_if {|t| t[0] != '#' }
      tags.each {|m| m[0] = ''}

      now = Time.now
      commits = current_user.commits.active.joins(:goal)
                                            .where("goals.checkin_with = ?", current_user.checkin_with)
                                            .where("goals.hash_tag in (?)", tags)
                                            .where("commits.starts_at < ?", now)
                                            .group('commits.goal_id')

      # raise commits.inspect

      raise 'There are no commitments to check in.' if commits.blank?

      updates = { state: 1, note: text, checked_by: 'upmit', checked_at: now }

      if params[:photo].present?
        updates.merge({ photo: params[:photo]})
      elsif params[:remote_photo_url].present?
        updates.merge({ remote_photo_url: params[:remote_photo_url]})
      end

      Commit.transaction do
        commits.each do |c|
          c.update updates
        end
      end
      
      auth = current_user.authorizations.find_by provider: current_user.checkin_with
      post_service = "#{ current_user.checkin_with.capitalize }PostService".constantize.new(auth)
      
      post_service.delay.post(current_user, text)

    rescue => error
      @error = error
    end
  end

  def update
    @commit.note = params[:note]

    if params[:photo].present?
      @commit.photo = params[:photo]
    elsif params[:remote_photo_url].present?
      @commit.remote_photo_url = params[:remote_photo_url]
    end

    unless @commit.save
      @error = 'There has been some problem. Please try again later.'
    end
  end

  private
  def find_commit
    id = params[:commit_id] || params[:id]

    @commit = current_user.commits.find(id)
  end
end
