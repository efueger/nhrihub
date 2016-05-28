class ComplaintsController < ApplicationController
  def index
    @complaints = Complaint.all
    @mandates = Mandate.all
    @agencies = Agency.all
    @complaint_bases = [ GoodGovernance::ComplaintBasis.named_list,
                         Nhri::ComplaintBasis.named_list,
                         Siu::ComplaintBasis.named_list]
    @next_case_reference = Complaint.next_case_reference
  end

  def create
    complaint = Complaint.new(complaint_params)
    if complaint.save
      render :json => complaint, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def complaint_params
    params.require(:complaint).permit(:case_reference, :complainant, :village, :phone, :mandate_ids => [],
        :good_governance_complaint_basis_ids => [], :special_investigations_unit_complaint_basis_ids => [], :human_rights_complaint_basis_ids => [])
  end
end
