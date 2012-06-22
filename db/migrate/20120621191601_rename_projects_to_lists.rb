class RenameProjectsToLists < ActiveRecord::Migration
  def up
    rename_table :projects, :lists
    change_table :lists do |t|
      t.boolean :is_public
    end
    rename_table :project_members, :list_members
    rename_column :list_members , :project_id, :list_id
    rename_table :project_questions, :list_questions
    rename_column :list_questions, :project_id, :list_id
  end

  def down
    rename_table :lists, :projects
    change_table :projects do |t|
      t.remove :is_public
    end
    rename_table :list_members, :project_members
    rename_column :project_members, :list_id, :project_id
    rename_table :list_questions, :project_questions
    rename_column :project_questions, :list_id, :project_id
  end
end