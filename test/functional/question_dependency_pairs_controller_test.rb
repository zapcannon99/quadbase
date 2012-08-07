# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QuestionDependencyPairsControllerTest < ActionController::TestCase
  
	setup do
		@user = FactoryGirl.create(:user)
		@qdp = FactoryGirl.create(:question_dependency_pair)
	end

  test "should not create new dependency not logged in" do
  end
end
