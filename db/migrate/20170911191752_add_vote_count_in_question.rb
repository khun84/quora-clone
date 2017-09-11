class AddVoteCountInQuestion < ActiveRecord::Migration[5.1]
	def change
    add_column :questions, :upvote_count, :integer, default: 0
    add_column :questions, :downvote_count, :integer, default: 0
	end
end
