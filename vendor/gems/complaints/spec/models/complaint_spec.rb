require 'rails_helper'

describe "complaint" do
  context "create" do
    before do
      @complaint = Complaint.create({:status_changes_attributes => [{:name => nil}]})
    end
    it "should create a status_change and link to 'Under Evaluation' complaint status" do
      expect(@complaint.status_changes.length).to eq 1
      expect(@complaint.complaint_statuses.length).to eq 1
      expect(@complaint.complaint_statuses.first.name).to eq "Under Evaluation"
      expect(@complaint.current_status_humanized).to eq "Under Evaluation"
    end
  end

  context "update status" do
    before do
      @complaint = Complaint.create({:status_changes_attributes => [{:name => nil}]})
      @complaint.update({:status_changes_attributes => [{:name => "Active"}]})
    end

    it "should create a status change object and link to the Active complaint status" do
      expect(@complaint.status_changes.length).to eq 2
      expect(@complaint.complaint_statuses.map(&:name)).to eq ["Under Evaluation", "Active"]
    end
  end

  context "update Complaint with no status change" do
    before do
      @complaint = Complaint.create({:status_changes_attributes => [{:name => nil}]})
      @complaint.update({:status_changes_attributes => [{:name => "Active"}]})
      @complaint.update({:status_changes_attributes => [{:name => "Active"}]})
    end

    it "should create a status change object and link to the Active complaint status" do
      expect(@complaint.status_changes.length).to eq 2
      expect(@complaint.complaint_statuses.map(&:name)).to eq ["Under Evaluation", "Active"]
    end
  end
end

# just confirming here that the unusual associations work as expected

describe "Complaint with siu complaint basis" do
  before do
    @complaint = Complaint.create
    @siu_complaint_basis = Siu::ComplaintBasis.create(:name => "A thing")
    @complaint.special_investigations_unit_complaint_bases << @siu_complaint_basis
    @complaint.save
  end

  it "should be saved with the associations" do
    expect(@complaint.special_investigations_unit_complaint_bases.count).to eq 1
    expect(@complaint.special_investigations_unit_complaint_bases.first.name).to eq "A thing"
    expect(Siu::ComplaintBasis.count).to eq 1
    expect(ComplaintComplaintBasis.count).to eq 1
    expect(@complaint.special_investigations_unit_complaint_bases.first.type).to eq "Siu::ComplaintBasis"
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
  let(:this_year_case_reference) { "C"+current_year+"-22" }
  context "existing Complaints are from previous year" do
    before do
      Complaint.create(:case_reference => 'C12-35')
    end

    it "should start the sequence at 1 with the current year" do
      expect(Complaint.next_case_reference).to eq("C#{ current_year }-1")
    end
  end

  context "existing Complaints are from the current year" do
    before do
      Complaint.create(:case_reference => this_year_case_reference)
    end
    it "should increment the sequence only" do
      expect(Complaint.next_case_reference).to eq("C#{current_year}-23")
    end
  end

  context "no existing complaints" do
    before do
      # nothing!
    end

    it "should create the first case reference for the current year" do
      expect(Complaint.next_case_reference).to eq("C#{ current_year }-1")
    end
  end
end

describe "sort algorithm" do
  before do
    Complaint.create(:case_reference => "C16-2")
    Complaint.create(:case_reference => "C16-1")
    Complaint.create(:case_reference => "C16-3")
  end

  it "should sort by ascending case reference" do
    expect(Complaint.all.sort.pluck(:case_reference)).to eq ["C16-1","C16-2","C16-3"]
  end
end

describe "#index_url" do
  before do
    @complaint = Complaint.create(:case_reference => 'C12-35')
  end

  it "should contain protocol, host, locale, complaints path, and case_reference query string" do
    route = Rails.application.routes.recognize_path(@complaint.index_url)
    expect(route[:locale]).to eq I18n.locale.to_s
    url = URI.parse(@complaint.index_url)
    expect(url.host).to eq SITE_URL
    expect(url.path).to eq "/en/complaints"
    params = CGI.parse(url.query)
    expect(params.keys.first).to eq "case_reference"
    expect(params.values.first).to eq ["C12-35"]
  end
end
