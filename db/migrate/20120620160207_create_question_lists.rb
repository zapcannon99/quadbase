class CreateQuestionLists < ActiveRecord::Migration
  def change
    create_table :question_lists do |t|

      t.timestamps
    end
  end
end
