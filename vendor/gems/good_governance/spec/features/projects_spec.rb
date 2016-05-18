require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/good_governance_context_projects_spec_helpers'
require 'projects_spec_common_helpers'

feature "projects index", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  include GoodGovernanceContextProjectsSpecHelpers
  include ProjectsSpecCommonHelpers
  #it_behaves_like "projects"

  it "should show a list of projects" do
    expect(page_heading).to eq "#{heading_prefix} Projects"
    expect(page_title).to eq "#{heading_prefix} Projects"
    expect(project_model.count).to eq 2
    expect(projects_count).to eq 2
  end

  it "shows expanded information for each of the projects" do
    expand_last_project
    within last_project do
      last_project = Project.find(2)
      expect(find('.basic_info .title').text).to eq last_project.title
      expect(find('.description .no_edit span').text).to eq last_project.description
      last_project.mandates.each do |mandate|
        expect(all('#mandates .mandate').map(&:text)).to include mandate.name
      end
      within project_types do
        within good_governance_mandate do
          last_project.good_governance_project_types.each do |project_type|
            expect(all('.project_type').map(&:text)).to include project_type.name
          end
        end
      end
      within agencies do
        last_project.agencies.each do |agency|
          expect(all('.agency').map(&:text)).to include agency.name
        end
      end
      within conventions do
        last_project.conventions.each do |convention|
          expect(all('.convention').map(&:text)).to include convention.name
        end
      end
      within performance_indicators do
        last_project.performance_indicators.each do |performance_indicator|
          expect(all('.performance_indicator').map(&:text)).to include performance_indicator.indexed_description
        end
      end
      within project_documents do
        last_project.project_documents.each do |project_document|
          expect(all('.project_document .title').map(&:text)).to include project_document.title
        end
      end
    end
  end

  it "adds a project that does not have a file attachment" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "new project description")
    check('Good Governance')

    within good_governance_types do
      check('Consultation')
    end

    within agencies do
      check('MJCA')
    end

    within conventions do
      check('ICERD')
    end

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator

    # SAVE IT
    page.execute_script("scrollTo(0,0)")
    expect{ save_project.click; wait_for_ajax }.to change{ project_model.count }.from(2).to(3)

    # CHECK SERVER
    pi = PerformanceIndicator.first
    project = GoodGovernance::Project.last
    expect(project.performance_indicator_ids).to eq [pi.id]
    expect(projects_count).to eq 3
    expect(project.title).to eq "new project title"
    expect(project.description).to eq "new project description"
    mandate = Mandate.find_by(:key => "good_governance")
    expect(project.mandate_ids).to include mandate.id

    # CHECK CLIENT
    expand_first_project
    within first_project do
      expect(find('.project .basic_info .title').text).to eq "new project title"
      expect(find('.description .no_edit span').text).to eq "new project description"
      expect(all('#mandates .mandate').map(&:text)).to include 'Good Governance'
      within project_types do
        within good_governance_mandate do
          expect(all('.project_type').map(&:text)).to include 'Consultation'
        end
      end
      within agencies do
        expect(all('.agency').map(&:text)).to include "MJCA"
      end
      within conventions do
        expect(all('.convention').map(&:text)).to include "ICERD"
      end
      within performance_indicators do
        expect(find('.performance_indicator').text).to eq pi.indexed_description
      end
    end
  end

  it "adds a project that has a file attachment" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "new project description")
    check('Good Governance')

    within good_governance_types do
      check('Consultation')
    end

    within agencies do
      check('MJCA')
    end

    within conventions do
      check('ICERD')
    end

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator

    within new_project do
      attach_file(:first_time)
      fill_in("project_document_title", :with => "Project Document")
    end
    expect(page).to have_selector("#documents .document .filename", :text => "upload_file.pdf")

    within new_project do
      attach_file
      page.all("#project_document_title")[0].set("Title for an analysis document")
    end
    expect(page).to have_selector("#documents .document .filename", :text => "upload_file.pdf", :count => 2)

    # SAVE IT
    page.execute_script("scrollTo(0,0)")
    expect{ save_project.click; wait_for_ajax }.to change{ project_model.count }.from(2).to(3).
                                             and change{ ProjectDocument.count }.by(2)

    # CHECK SERVER
    pi = PerformanceIndicator.first
    project = GoodGovernance::Project.last
    expect(project.performance_indicator_ids).to eq [pi.id]
    expect(projects_count).to eq 3
    expect(project.title).to eq "new project title"
    expect(project.description).to eq "new project description"
    mandate = Mandate.find_by(:key => "good_governance")
    expect(project.mandate_ids).to include mandate.id

    expect(project.project_documents.count).to eq 2
    expect(project.project_documents.map(&:title)).to include "Project Document"
    expect(project.project_documents.map(&:title)).to include "Title for an analysis document"

    # CHECK CLIENT
    expand_first_project
    within first_project do
      expect(find('.basic_info .title').text).to eq "new project title"
      expect(find('.description .no_edit span').text).to eq "new project description"
      expect(all('#mandates .mandate').map(&:text)).to include 'Good Governance'
      within project_types do
        within good_governance_mandate do
          expect(all('.project_type').map(&:text)).to include 'Consultation'
        end
      end
      within agencies do
        expect(all('.agency').map(&:text)).to include "MJCA"
      end
      within conventions do
        expect(all('.convention').map(&:text)).to include "ICERD"
      end
      within performance_indicators do
        expect(find('.performance_indicator').text).to eq pi.indexed_description
      end
      within project_documents do
        expect(all('.project_document .title').map(&:text)).to include "Project Document"
        expect(all('.project_document .title').map(&:text)).to include "Title for an analysis document"
      end
    end
  end

  it "should restore list when cancelling add project" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "new project description")
    cancel_project.click
    expect(projects_count).to eq 2
    add_project.click
    expect(page.find('#project_title').value).to eq ""
    expect(page.find('#project_description').value).to eq ""
  end

  it "should remove performance indicator from the list during adding" do
    add_project.click

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator
    pi = PerformanceIndicator.first

    expect(page).to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description)
    remove_first_indicator.click
    wait_for_ajax
    expect(page).not_to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description)
  end

  it "should prevent adding duplicate performance indicators" do
    add_project.click

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator
    pi = PerformanceIndicator.first

    expect(page).to have_selector(".new_project #performance_indicators .selected_performance_indicator", :text => pi.indexed_description)

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator
    pi = PerformanceIndicator.first

    expect(page).to have_selector(".new_project #performance_indicators .selected_performance_indicator", :text => pi.indexed_description, :count => 1)
  end

  it "should show warning and not add when title is blank" do
    add_project.click
    fill_in('project_description', :with => "new project description")
    expect{ save_project.click; wait_for_ajax }.not_to change{ project_model.count }
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in('project_title', :with => 't')
    expect(page).not_to have_selector("#title_error", :text => "Title cannot be blank")
  end

  it "should show warning and not add when title is whitespace" do
    add_project.click
    fill_in('project_title', :with => "    ")
    fill_in('project_description', :with => "new project description")
    expect{ save_project.click; wait_for_ajax }.not_to change{ project_model.count }
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in('project_title', :with => 't')
    expect(page).not_to have_selector("#title_error", :text => "Title cannot be blank")
  end

  it "should show warning and not add when description is blank" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    expect{ save_project.click; wait_for_ajax }.not_to change{ project_model.count }
    expect(page).to have_selector("#description_error", :text => "Description cannot be blank")
    fill_in('project_description', :with => 't')
    expect(page).not_to have_selector("#description_error", :text => "Description cannot be blank")
  end

  it "should show warning and not add when description is whitespace" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "   ")
    expect{ save_project.click; wait_for_ajax }.not_to change{ project_model.count }
    expect(page).to have_selector("#description_error", :text => "Description cannot be blank")
    fill_in('project_description', :with => 't')
    expect(page).not_to have_selector("#description_error", :text => "Description cannot be blank")
  end

  it "should prevent adding more than one project at a time" do
    add_project.click
    add_project.click
    expect(page.all('.new_project').count).to eq 1
    cancel_project.click
    expect(page.all('.new_project').count).to eq 0
    add_project.click
    expect(page.all('.new_project').count).to eq 1
  end

  it "should delete a project" do
    expect{ delete_project_icon.click; wait_for_ajax }.to change{ project_model.count }.by(-1).
                                                   and change{ projects_count }.by(-1)
  end

  it "should edit a project" do
    edit_first_project.click
    #sleep(0.3) # css transition
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "new project description")
    check('Good Governance')
    check('Human Rights')

    within good_governance_types do
      check('Consultation')
    end

    within human_rights_types do
      check('Amicus Curiae')
    end

    within agencies do
      check('SAA')
    end

    within conventions do
      check('CEDAW')
    end

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    #page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator
    pi = PerformanceIndicator.first

    expect{ edit_save.click; wait_for_ajax }.to change{ project_model.find(1).title }.to("new project title")
    project = project_model.find(1)
    consultation_project_type = ProjectType.find_by(:name => "Consultation")
    expect( project.project_type_ids ).to include consultation_project_type.id
    amicus_project_type = ProjectType.find_by(:name => "Amicus Curiae")
    expect( project.project_type_ids ).to include amicus_project_type.id
    agency = Agency.find_by(:name => "SAA")
    expect( project.agency_ids ).to include agency.id
    convention = Convention.find_by(:name => "CEDAW")
    expect( project.convention_ids ).to include convention.id

    expand_first_project

    within first_project do
      expect(find('.basic_info .title').text).to eq "new project title"
      expect(find('.description .no_edit span').text).to eq "new project description"
      expect(all('.mandate').map(&:text)).to include 'Good Governance'
      within project_types do
        within good_governance_mandate do
          expect(all('.project_type').map(&:text)).to include 'Consultation'
        end
      end
      within agencies do
        expect(all('.agency').map(&:text)).to include "SAA"
      end
      within conventions do
        expect(all('.convention').map(&:text)).to include "CEDAW"
      end
      within performance_indicators do
        expect(all('.performance_indicator').map(&:text)).to include pi.indexed_description
      end
    end
  end

  it "should edit a project and remove performance indicators" do
    edit_first_project.click
    #sleep(0.3) # css transition
    expect{ remove_first_indicator.click; wait_for_ajax }.to change{ ProjectPerformanceIndicator.count }.by(-1).
                                                       and change{ page.all('.selected_performance_indicator').count }.by(-1)
  end

  # test this b/c of special handling of checkboxes in ractive
  it "should edit a project and save when all checkboxes are unchecked" do
    edit_last_project.click # has all associations checked
    uncheck_all_checkboxes
    project = project_model.last
    expect{ edit_save.click; wait_for_ajax }.to change{project.project_type_ids}.to([]).
                                          and change{project.agency_ids}.to([]).
                                          and change{project.convention_ids}.to([]).
                                          and change{project.mandate_ids}.to([])
  end

  it "should restore prior values if editing is cancelled" do
    edit_first_project.click
    #sleep(0.3) # css transition but now transitions turned off in test env
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "new project description")
    check('Good Governance')
    check('Human Rights')

    within good_governance_types do
      check('Consultation')
    end

    within human_rights_types do
      check('Amicus Curiae')
    end

    within agencies do
      check('SAA')
    end

    within conventions do
      check('CEDAW')
    end

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    select_first_performance_indicator

    edit_cancel

    expand_first_project

    project = project_model.first
    within first_project do
      expect(find('.basic_info .title').text).to eq project.title
      expect(find('.description .no_edit span').text).to eq project.description
      expect(all('.mandate .name').count).to eq 0
      expect(all('#project_types .project_type').count).to eq 0
      expect(all('#agencies .agency').count).to eq 0
      expect(all('#conventions .convention').count).to eq 0
      expect(all('.performance_indicator').count).to eq project.performance_indicator_ids.count
    end

    edit_first_project.click
    #sleep(0.3) # css transition

    expect(page.find('#project_title').value).to eq project.title
    expect(page.find('#project_description').value).to eq project.description
    expect(checkbox('good_governance')).not_to be_checked
    expect(checkbox('human_rights')).not_to be_checked
    expect(checkbox('project_type_1')).not_to be_checked
    expect(checkbox('project_type_2')).not_to be_checked
    expect(checkbox('project_type_3')).not_to be_checked
    expect(checkbox('project_type_4')).not_to be_checked
    expect(checkbox('project_type_5')).not_to be_checked
    expect(checkbox('agency_1')).not_to be_checked
    expect(checkbox('agency_2')).not_to be_checked
    expect(checkbox('convention_1')).not_to be_checked
    expect(checkbox('convention_2')).not_to be_checked
  end

  it "should show warning and not save when editing and title is blank" do
    edit_first_project.click
    fill_in('project_title', :with => '')
    expect{ edit_save.click; wait_for_ajax }.not_to change{ project_model.find(1).title }
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in('project_title', :with => 't')
    expect(page).not_to have_selector("#title_error", :text => "Title cannot be blank")
  end

  it "should show warning and not save edited project when title is whitespace" do
    edit_first_project.click
    fill_in('project_title', :with => "   ")
    expect{ edit_save.click; wait_for_ajax }.not_to change{ project_model.find(1).title }
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in('project_title', :with => 't')
    expect(page).not_to have_selector("#title_error", :text => "Title cannot be blank")
  end

  it "should show warning and not save edited project when description is blank" do
    edit_first_project.click
    fill_in('project_description', :with => "")
    expect{ edit_save.click; wait_for_ajax }.not_to change{ project_model.find(1).description }
    expect(page).to have_selector("#description_error", :text => "Description cannot be blank")
    fill_in('project_description', :with => 't')
    expect(page).not_to have_selector("#description_error", :text => "Description cannot be blank")
  end

  it "should show warning and not save edited project when description is whitespace" do
    edit_first_project.click
    fill_in('project_description', :with => "  ")
    expect{ edit_save.click; wait_for_ajax }.not_to change{ project_model.find(1).description }
    expect(page).to have_selector("#description_error", :text => "Description cannot be blank")
    fill_in('project_description', :with => 't')
    expect(page).not_to have_selector("#description_error", :text => "Description cannot be blank")
  end

  it "should terminate adding if editing is initiated" do
    add_project.click
    expect(page).to have_selector('.new_project')
    edit_first_project.click
    expect(page).not_to have_selector('.new_project')
  end

  it "should terminate editing if adding is initiated" do
    edit_first_project.click
    expect(page).to have_selector('#projects .project textarea#project_description', :visible => true)
    add_project.click
    expect(page).not_to have_selector('#projects .project textarea#project_description', :visible => true)
  end

  it "should prevent editing more than one project at at time" do
    edit_first_project.click
    edit_last_project.click
    expect(page).to have_selector('#projects .project textarea#project_description', :visible => true, :count => 1)
  end

  it "should not permit duplicate performance indicator associations to be added when editing" do
    edit_first_project.click

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    #page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator

    expect(page).to have_selector("#performance_indicators .selected_performance_indicator", :count => 3)
  end
end

feature "new project file management features", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  include GoodGovernanceContextProjectsSpecHelpers
  include ProjectsSpecCommonHelpers
  #it_behaves_like "new_project_file_management"

  it "should remove a selected file" do
    add_project.click

    within new_project do
      attach_file
      fill_in("project_document_title", :with => "Project Document")
      expect(page).to have_selector("#documents .document .filename", :text => "upload_file.pdf")
    end

    within new_project do
      attach_file
      page.all("#project_document_title")[1].set("Title for an analysis document")
      expect(page).to have_selector("#documents .document .filename", :text => "upload_file.pdf", :count => 2)
    end

    page.all("#documents .document .remove")[0].click
    expect(page).to have_selector("#documents .document .filename", :text => "upload_file.pdf", :count => 1)
    page.all("#documents .document .remove")[0].click
    expect(page).not_to have_selector("#documents .document .filename", :text => "upload_file.pdf")
  end

  it "shows filesize error if file is too big" do
    add_project.click
    within new_project do
      page.attach_file("project_file", big_upload_document, :visible => false)
    end
    expect(page).to have_selector('#filesize_error', :text => "File is too large")
  end

  it "shows filetype error for unpermitted file type" do
    set_permitted_filetypes # ['anything']
    add_project.click
    within new_project do
      page.attach_file("project_file", upload_image, :visible => false)
    end
    expect(page).to have_selector('#filetype_error', :text =>  "File type not allowed")
  end

  it "shows no filetypes configured error if no filetypes have been configured" do
    reset_permitted_filetypes # []
    add_project.click
    within new_project do
      page.attach_file("project_file", upload_document, :visible => false)
    end
    expect(page).to have_selector('#unconfigured_filetypes_error', :text => "No permitted file types have been configured")
  end

  #it "prevents duplicate named files from being added" do
    
  #end
end


feature "existing project file management features", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  include GoodGovernanceContextProjectsSpecHelpers
  include ProjectsSpecCommonHelpers
  #it_behaves_like "existing_project_file_management"

  it "should upload new files" do
    edit_first_project.click
    within edit_documents do
      attach_file
    end
    page.find("#project_document_title").set("New uploaded document")
    expect{ edit_save.click; wait_for_ajax }.to change{ project_model.first.project_documents.count }.from(2).to(3)
    expect(project_model.first.project_documents.map(&:title)).to include "New uploaded document"
    expect(all('.project_document .title').map(&:text)).to include "New uploaded document"
  end

  it "shows filesize error if file is too big" do
    edit_first_project.click
    add_project.click
    within new_project do
      page.attach_file("project_file", big_upload_document, :visible => false)
    end
    expect(page).to have_selector('#filesize_error', :text => "File is too large")
  end

  it "shows filetype error for unpermitted file type" do
    set_permitted_filetypes # ['anything']
    edit_first_project.click
    add_project.click
    within new_project do
      page.attach_file("project_file", upload_image, :visible => false)
    end
    expect(page).to have_selector('#filetype_error', :text =>  "File type not allowed")
  end

  it "replaces named files" do
    edit_last_project.click
    within edit_documents do
      attach_file
    end
    page.find("#project_document_title").set("Final Report")
    expect{ edit_save.click; wait_for_ajax }.not_to change{ ProjectDocument.count }
  end

  it "adds files to the files list if they are not 'named files'" do
    edit_last_project.click
    within edit_documents do
      attach_file
    end
    page.find("#project_document_title").set("Any old title")
    expect{ edit_save.click; wait_for_ajax }.to change{ ProjectDocument.count }.by(1)
  end

  it "should delete files" do
    edit_last_project.click
    expect{ delete_file.click; wait_for_ajax }.to change{ ProjectDocument.count }.by(-1).
                                               and change{ project_documents.all('.project_document').count }.by(-1)
  end

  # can't test download in chrome or firefox
  it "can download the saved document", :driver => :poltergeist do
    @doc = Project.last.project_documents.first
    expand_last_project
    click_the_download_icon
    expect(page.response_headers['Content-Type']).to eq('application/pdf')
    filename = @doc.filename
    expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
  end

  it "panel expanding should behave" do
    edit_first_project.click
    edit_save.click
    wait_for_ajax
    expect(page.evaluate_script("projects.findAllComponents('project')[0].get('expanded')")).to eq true
    expect(page.evaluate_script("projects.findAllComponents('project')[0].get('editing')")).to eq false
    edit_first_project.click
    expect(page.evaluate_script("projects.findAllComponents('project')[0].get('expanded')")).to eq true
    expect(page.evaluate_script("projects.findAllComponents('project')[0].get('editing')")).to eq true
  end
end