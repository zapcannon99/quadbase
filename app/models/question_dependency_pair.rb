# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QuestionDependencyPair < ActiveRecord::Base
  # This class records a pair of questions in one of the following circumstances:
  #
  # 1) Sometimes if someone solves question A, it will be easier for them to 
  #    solve question B.  In this case, A is a supporting question to B.  B is a
  #    supported question of A.
  #
  # 2) Sometimes question A is required to be shown before question B.  In this
  #    situation, question A is called a prerequisite of question B.  Question B
  #    is called a dependent of question A.
  #
  # Generically, since question B depends on question A in both of these cases
  # we call question A the independent question and question B the dependent
  # question.  The two types above are separated by the "kind" attribute, which
  # can either be "support" or "requirement" for the two cases, respectively.

  belongs_to :independent_question, :class_name => "Question"  
  belongs_to :dependent_question, :class_name => "Question"

  validates_uniqueness_of :independent_question_id, 
                          :scope => [:dependent_question_id, :kind],
                          :message => "This combination already exists."

  validate :dependent_question_unpublished
  validate :valid_kind

  attr_accessible :independent_question_id, :dependent_question_id, :kind

  def derive_dependency(derived_question, multipart_question)
    dq = derived_question.becomes(derived_question.base_class)
    multipart_question.child_questions.each do |cq|
      qp = cq.becomes(cq.base_class)
      if qp.id == independent_question_id || qp.id == dependent_question_id
        if dq.question_source.source_question_id == independent_question.id
          if qp.id == dependent_question_id
            QuestionDependencyPair.create({ :independent_question_id => dq.id,
                                            :dependent_question_id => qp.id,
                                            :kind => kind })
          elsif qp.source_question.id == dependent_question_id
            pair = QuestionDependencyPair.where({ :independent_question_id => independent_question_id,
                                                  :dependent_question_id => qp.id,
                                                  :kind => kind })
            pair.independent_question_id = dq.id
            pair.save!
          end
        elsif dq.question_source.source_question_id == dependent_question.id
          if qp.id == independent_question_id
            QuestionDependencyPair.create({ :independent_question_id => qp.id,
                                            :dependent_question_id => dq.id,
                                            :kind => kind })
          elsif qp.source_question.id == independent_question_id
            pair = QuestionDependencyPair.where({ :independent_question_id => qp.id,
                                                  :dependent_question_id => dependent_question_id,
                                                  :kind => kind })
            pair.independent_question_id = dq.id
            pair.save!
          end
        end
      end
    end
  end

  def is_requirement?
    "requirement" == kind
  end

  def is_support?
    "support" == kind
  end

  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_read_by?(user)
    !user.is_anonymous? &&
    user.can_read?(dependent_question) && 
    user.can_read?(independent_question)
  end

  def can_be_created_by?(user)
    !user.is_anonymous? && user.can_update?(dependent_question)
  end

  def can_be_destroyed_by?(user)
    !user.is_anonymous? && user.can_update?(dependent_question)
  end

protected

  # We're only allowing the editors of a draft question to specify whether 
  # that question is supported by another question.  
  def dependent_question_unpublished
    return if !dependent_question.is_published?
    self.errors.add(:base, "A question pair can only be set if the " + 
                           "dependent question is unpublished")
    false
  end  
  
  def valid_kind
    return if is_requirement? || is_support?
    self.errors.add(:base, "This pair must either be for a requirement or a support.")
    false
  end

end
