class AddApprovalCommentsAndApprovedByToDeliverables < ActiveRecord::Migration
  def change
    add_column :deliverables, :approval_comments, :text
    add_column :deliverables, :approved_by, :string
  end
end
