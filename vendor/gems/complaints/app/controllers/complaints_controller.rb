class ComplaintsController < ApplicationController
  def index
    #@complaints = Complaint.all
    @complaints = Complaint.includes(:assigns,
                                     :mandate,
                                     {:status_changes => :complaint_status},
                                     {:complaint_good_governance_complaint_bases=>:good_governance_complaint_basis},
                                     {:complaint_special_investigations_unit_complaint_bases => :special_investigations_unit_complaint_basis},
                                     {:complaint_human_rights_complaint_bases=>:human_rights_complaint_basis},
                                     {:complaint_agencies => :agency},
                                     :communications,
                                     :complaint_categories,
                                     :complaint_documents,
                                     :reminders,:notes).sort.reverse
    @mandates = Mandate.all
    @agencies = Agency.all
    @complaint_bases = [ GoodGovernance::ComplaintBasis.named_list,
                         Nhri::ComplaintBasis.named_list,
                         Siu::ComplaintBasis.named_list]
    @next_case_reference = Complaint.next_case_reference
    @users = User.all
    @categories = ComplaintCategory.all
    @good_governance_complaint_bases = GoodGovernance::ComplaintBasis.all
    @human_rights_complaint_bases = Nhri::ComplaintBasis.all
    @special_investigations_unit_complaint_bases = Siu::ComplaintBasis.all
    @staff = User.staff.order(:lastName,:firstName).select(:id,:firstName,:lastName)
    @maximum_filesize = ComplaintDocument.maximum_filesize * 1000000
    @permitted_filetypes = ComplaintDocument.permitted_filetypes.to_json
    @communication_maximum_filesize    = CommunicationDocument.maximum_filesize * 1000000
    @communication_permitted_filetypes = CommunicationDocument.permitted_filetypes.to_json
    @statuses = ComplaintStatus.select(:id, :name).all
  end

  def create
    params[:complaint].delete(:current_status_humanized)
    complaint = Complaint.new(complaint_params)
    if params[:complaint][:date]
      date = params[:complaint][:date]
    else
      date = DateTime.now
    end
    complaint.status_changes_attributes = [{:user_id => current_user.id, :name => "Under Evaluation"}]
    if complaint.save
      render :json => complaint, :status => 200
    else
      render :plain => complaint.errors.full_messages, :status => 500
    end
  end

  def update
    complaint = Complaint.find(params[:id])
    params[:complaint][:status_changes_attributes] = [{:user_id => current_user.id, :name => params[:complaint].delete(:current_status_humanized)}]
    if complaint.update(complaint_params)
      render :json => complaint, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy
    complaint = Complaint.find(params[:id])
    complaint.destroy
    head :ok
  end

  private
  def complaint_params
    params.require(:complaint).permit( :case_reference, :complainant, :village, :phone, :new_assignee_id,
                                       :mandate_name, :imported, :good_governance_complaint_basis_ids => [],
                                       :special_investigations_unit_complaint_basis_ids => [],
                                       :human_rights_complaint_basis_ids => [],
                                       :status_changes_attributes => [:user_id, :name],
                                       :complaint_category_ids => [], :agency_ids => [],
                                       :complaint_documents_attributes => [:file, :title, :filename, :original_type, :filesize, :lastModifiedDate],
                                     )
  end
end
