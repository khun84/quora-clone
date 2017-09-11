class CreateQuestionVotes < ActiveRecord::Migration[5.1]
	def change
    create_table :question_votes do |t|
      t.belongs_to :question
      t.belongs_to :user
      t.string :direction
    end
	end
end
