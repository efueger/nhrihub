require 'rails_helper'

# just confirming here that the unusual associations work as expected

describe "Complaint with siu complaint basis" do
  before do
    @complaint = Complaint.create
    @siu_complaint_basis = Siu::ComplaintBasis.create(:name => "A thing")
    @complaint.siu_complaint_bases << @siu_complaint_basis
    @complaint.save
  end

  it "should be saved with the associations" do
    expect(@complaint.siu_complaint_bases.count).to eq 1
    expect(@complaint.siu_complaint_bases.first.name).to eq "A thing"
    expect(Siu::ComplaintBasis.count).to eq 1
    expect(ComplaintComplaintBasis.count).to eq 1
    expect(@complaint.siu_complaint_bases.first.type).to eq "Siu::ComplaintBasis"
  end
end

describe "Complaint with gg complaint basis" do
  before do
    @complaint = Complaint.create
    @good_governance_complaint_basis = GoodGovernance::ComplaintBasis.create(:name => "A thing")
    @complaint.good_governance_complaint_bases << @good_governance_complaint_basis
    @complaint.save
  end

  it "should be saved with the associations" do
    expect(@complaint.good_governance_complaint_bases.count).to eq 1
    expect(@complaint.good_governance_complaint_bases.first.name).to eq "A thing"
    expect(GoodGovernance::ComplaintBasis.count).to eq 1
    expect(ComplaintComplaintBasis.count).to eq 1
    expect(@complaint.good_governance_complaint_bases.first.type).to eq "GoodGovernance::ComplaintBasis"
  end
end

describe "Complaint with hr complaint basis" do
  before do
    @complaint = Complaint.create
    @human_rights_complaint_basis = Nhri::ComplaintBasis.create(:name => "A thing")
    @complaint.human_rights_complaint_bases << @human_rights_complaint_basis
    @complaint.save
  end

  it "should be saved with the associations" do
    expect(@complaint.human_rights_complaint_bases.count).to eq 1
    expect(@complaint.human_rights_complaint_bases.first.name).to eq "A thing"
    expect(Nhri::ComplaintBasis.count).to eq 1
    expect(Convention.count).to eq 1
    expect(ComplaintComplaintBasis.count).to eq 1
  end
end

describe "next case reference" do
  let(:current_year){ Date.today.strftime('%y') }
  let(:this_year_case_reference) { "C"+current_year+"/22" }
  context "existing Complaints are from previous year" do
    before do
      Complaint.create(:case_reference => 'C12/35')
    end

    it "should start the sequence at 1 with the current year" do
      expect(Complaint.next_case_reference).to eq("C#{ current_year }/1")
    end
  end

  context "existing Complaints are from the current year" do
    before do
      Complaint.create(:case_reference => this_year_case_reference)
    end
    it "should increment the sequence only" do
      expect(Complaint.next_case_reference).to eq("C#{current_year}/23")
    end
  end

  context "no existing complaints" do
    before do
      # nothing!
    end

    it "should create the first case reference for the current year" do
      expect(Complaint.next_case_reference).to eq("C#{ current_year }/1")
    end
  end
end
