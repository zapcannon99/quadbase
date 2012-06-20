class QuestionList < ActiveRecord::Base
  # attr_accessible :title, :body
  
  has_many :question_list_members, :dependent => :destroy
  has_many :members, :through => :question_list_members, :source => :user
  
  has_many :question_list_questions, :dependent => :destroy
  has_many :questions, :through => :question_list_questions
  
  accepts_nested_attributes_for :question_list_members, :allow_destroy => true
  accepts_nested_attributes_for :question_list_questions, :allow_destroy => true

  attr_accessible :name, :question_list_members_attributes, :question_list_questions_attributes  
  
  def add_member!(member)
    QuestionList.create(:question_list => self, :user => member)
  end
  
  def is_member?(user)
    members.include?(user)
  end
  
  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_read_by?(user)
    !user.is_anonymous? && is_member?(user)
  end
    
  def can_be_created_by?(user)
    !user.is_anonymous?
  end
  
  def can_be_updated_by?(user)
    !user.is_anonymous? && is_member?(user)
  end
  
  def can_be_destroyed_by?(user)
    !user.is_anonymous? && is_member?(user)
  end
  
  
end
