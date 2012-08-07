# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QuestionDependencyPairTest < ActiveSupport::TestCase

  test "basic" do
    qdp = FactoryGirl.build(:question_dependency_pair)
    assert_not_nil qdp.independent_question
    assert_not_nil qdp.dependent_question
    
    assert qdp.is_requirement?
    assert !qdp.is_support?
  end
  
  test "dependent can't be published" do
    sq_pub = make_simple_question({:published => true, :method => :create})
    sq_unpub = make_simple_question({:published => false, :method => :create})
    
    assert_nothing_raised{
      FactoryGirl.create(:question_dependency_pair,
                     :independent_question => sq_pub,                    
                     :dependent_question => sq_unpub)}

    assert_raise(ActiveRecord::RecordInvalid) {
      FactoryGirl.create(:question_dependency_pair,
                     :independent_question => sq_unpub, 
                     :dependent_question => sq_pub)
    }                                
  end
  
  test "no duplicate pairs" do
    qdp = FactoryGirl.create(:question_dependency_pair, :kind => "requirement")
    
    assert_raise(ActiveRecord::RecordInvalid) {
      FactoryGirl.create(:question_dependency_pair,
                     :independent_question => qdp.independent_question, 
                     :dependent_question => qdp.dependent_question,
                     :kind => "requirement")
    }
    
    assert_nothing_raised {
      FactoryGirl.create(:question_dependency_pair,
                     :independent_question => qdp.independent_question, 
                     :dependent_question => qdp.dependent_question,
                     :kind => "support")
    }
  end
  
  test "is_requirement" do
    qdp = FactoryGirl.create(:question_dependency_pair, :kind => "requirement")
    assert qdp.is_requirement?
  end
  
  test "is_support" do
    qdp = FactoryGirl.create(:question_dependency_pair, :kind => "support")
    assert qdp.is_support?
  end

  # Next few tests make sure that the derive_dependency function works correctly
  # The case for this test is that a person has already unlocked the dependent,
  # and unlock the independent. Rather than make a new pair, the pair will update the existing pair
  # to conserve space in the SQL database.
  test "should update dependency when published independent derived and unpublished dependent" do
    u = FactoryGirl.create(:user)
    iq = make_simple_question(:set_license => true)
    iq.create!(u)
    iq.publish!(u)
    dq = FactoryGirl.create(:simple_question)
    qdp = FactoryGirl.create(:question_dependency_pair, :independent_question => iq, :dependent_question => dq, :kind => "support") #kind doesn't matter
    qdp.independent_question.new_derivation!(u)
    derived_question = Question.find(:last)
    assert iq != Question.find(:last)
    assert derived_question.source_question == qdp.independent_question
    assert derived_question.source_question == iq
    original_qdp = QuestionDependencyPair.new
    original_qdp.attributes = qdp.attributes
    qdp.derive_dependency("independent", derived_question)
    qdp.reload
    derived_qdp = QuestionDependencyPair.find(:last)
    assert derived_qdp.independent_question == derived_question
    assert qdp.independent_question.source_question == iq
    assert qdp.dependent_question == dq
    assert qdp.kind == "support"
  end
=begin
  test "should create new dependency when published dependent derived and published independent" do
    u = FactoryGirl.create(:user)
    iq = make_simple_question(:set_license => true)
    iq.create!(u)
    iq.publish!(u)
    dq = make_simple_question(:set_license => true)
    dq.create!(u)
    dq.publish!(u)
    original_qdp = FactoryGirl.create(:question_dependency_pair, :dependent_question => dq)
    original_qdp.dependent_question.new_derivation!(u)
    derived_question = Question.find(:last)
    assert derived_question.source_question == original_qdp.dependent_question

    derived_qdp = original_qdp.derive_dependency("dependent", derived_question)
    assert derived_qdp.independent_question == original_qdp.independent_question
    assert derived_qdp.dependent_question == original_qdp.dependent_question
    assert derived_qdp.kind == original_qdp.kind
  end
=end
end
