class Upvote < ApplicationRecord
  belongs_to :proposal
  belongs_to :user
  validates :user_id, uniqueness: { scope: :proposal_id }
  validate :guest_cant_upvote
  # Everything behind is for WS, at each save or destroy refresh on all clients
  after_save :broadcast_upvotes
  after_destroy :broadcast_upvotes

  def broadcast_upvotes
    # looking for all clients on the broadcast and push upvotes size and proposal id
    if proposal
      ActionCable.server.broadcast(
      "upvote_#{proposal.choogle.slug}",
      upvotes: self.proposal.upvotes.size,
      proposal_id: self.proposal.id,
      user_id: self.user.id,
      upvoters: self.proposal.upvoters,
      )
    end
  end

  def guest_cant_upvote
    errors.add(:base, "Fill your name if you want to upvote") if user.first_name == "guest"
  end
end
