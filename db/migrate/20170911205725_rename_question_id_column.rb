class RenameQuestionIdColumn < ActiveRecord::Migration[5.1]
	def change
    rename_column :question_votes, :question_id, :article_id
	end
end
