class ComplaintAdminController < ApplicationController
  def show
    @good_governance_complaint_basis = GoodGovernance::ComplaintBasis.new
    @good_governance_complaint_bases = GoodGovernance::ComplaintBasis.pluck(:name)
    @siu_complaint_basis = Siu::ComplaintBasis.new
    @siu_complaint_bases = Siu::ComplaintBasis.pluck(:name)
    @complaint_category = ComplaintCategory.new
    @complaint_categories = ComplaintCategory.pluck(:name)
  end
end
