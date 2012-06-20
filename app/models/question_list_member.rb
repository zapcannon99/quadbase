class QuestionListMember < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  belongs_to :question_list
  
  attr_accessible :user, :question_list, :user_id
  
  
  
  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_created_by?(user)
    !user.is_anonymous? && question_list.is_member?(user)
  end

  def can_be_updated_by?(user)
    !user.is_anonymous? && user == self.user
  end
  
  def can_be_destroyed_by?(user)
    !user.is_anonymous? && question_list.is_member?(user)
  end
  
  
end
