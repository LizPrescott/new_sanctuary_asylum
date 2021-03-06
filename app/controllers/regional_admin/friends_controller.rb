class RegionalAdmin::FriendsController < RegionalAdminController
  before_action :find_friend, only: [:show, :update]

  def index
    @friends = current_region.friends.with_active_applications.order('created_at desc')
  end

  def show; end

  def update
    if @friend.update_attributes(user_friend_associations_params)
      flash[:success] = 'Changes successfully saved.'
    else
      flash[:error] = 'Something went wrong. Please try again.'
    end
    redirect_to regional_admin_region_friend_path(current_region, @friend)
  end

  private

  def find_friend
    @friend = Friend.find_by(id: params[:id])
  end

  def user_friend_associations_params
    persisted_lawyer_ids = @friend.remote_clinic_lawyers.map(&:id)
    lawyer_ids_params = friend_params[:user_ids].map{ |id| id.to_i if id.present? }.compact
    added_lawyer_ids = lawyer_ids_params - persisted_lawyer_ids
    removed_lawyer_ids = persisted_lawyer_ids - lawyer_ids_params

    user_friend_associations_attributes = []
    added_lawyer_ids.each do |user_id|
      user_friend_associations_attributes << { user_id: user_id, friend_id: @friend.id, remote: true }
    end

    removed_lawyer_ids.each do |user_id|
      id = UserFriendAssociation.where(user_id: user_id, friend_id: @friend.id, remote: true).first.id
      user_friend_associations_attributes << { id: id, _destroy: '1' }
    end
    { user_friend_associations_attributes: user_friend_associations_attributes }
  end

  def friend_params
    params.require(:friend).permit(user_ids: [])
  end
end
