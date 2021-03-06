require 'rspec/core/shared_context'

module MediaAdminSpecHelpers
  extend RSpec::Core::SharedContext

  def setup_default_audience_types
    AudienceType::DefaultValues.each do |at|
      AudienceType.create(:short_type => at.short_type, :long_type => at.long_type)
    end
  end

  def audience_types_long_descriptions
    page.all('#audience_types .audience_type .long_type').map(&:text)
  end

  def audience_types_short_descriptions
    page.all('#audience_types .audience_type .short_type').map(&:text)
  end

  def add_audience_type
    page.find('button#add_audience_type')
  end

  def delete_first_audience_type
    page.all('.delete_audience_type').first.click
  end

  def subareas
    page.all('.subarea .name').map(&:text)
  end

  def open_accordion_for_area(text)
    target_area = area_called(text)
    target_area.find('#subareas_link').click
    accordion_element = target_area.find(:xpath, "./parent::*/div[contains(@class,'collapse')]")['id']
    wait_for_accordion("#"+accordion_element)
  end

  def area_called(text)
    page.find('.row.area', :text => text)
  end

  def remove_add_delete_fileconfig_permissions
    ActionRole.
      joins(:action => :controller).
      where('actions.action_name' => ['create', 'destroy', 'update'],
            'controllers.controller_name' => ['media_appearance/filetypes','media_appearance/filesizes']).
      destroy_all
  end

  def create_default_areas
    ["Human Rights", "Good Governance", "Special Investigations Unit", "Corporate Services"].each do |a|
      Area.create(:name => a)
    end
    human_rights_id = Area.where(:name => 'Human Rights').first.id
    [{:area_id => human_rights_id, :name => "Violation", :full_name => "Violation"},
    {:area_id => human_rights_id, :name => "Education activities", :full_name => "Education activities"},
    {:area_id => human_rights_id, :name => "Office reports", :full_name => "Office reports"},
    {:area_id => human_rights_id, :name => "Universal periodic review", :full_name => "Universal periodic review"},
    {:area_id => human_rights_id, :name => "CEDAW", :full_name => "Convention on the Elimination of All Forms of Discrimination against Women"},
    {:area_id => human_rights_id, :name => "CRC", :full_name => "Convention on the Rights of the Child"},
    {:area_id => human_rights_id, :name => "CRPD", :full_name => "Convention on the Rights of Persons with Disabilities"}].each do |attrs|
      Subarea.create(attrs)
    end

    good_governance_id = Area.where(:name => "Good Governance").first.id

    [{:area_id => good_governance_id, :name => "Violation", :full_name => "Violation"},
    {:area_id => good_governance_id, :name => "Office report", :full_name => "Office report"},
    {:area_id => good_governance_id, :name => "Office consultations", :full_name => "Office consultations"}].each do |attrs|
      Subarea.create(attrs)
    end
  end

  def click_delete_for(area, subarea=nil)
    if subarea
      open_subarea_panel_for_area(area)
      page.find(:xpath, ".//div[@class='panel panel-default'][.//div[contains(text(),'#{area}')]]//div[@class='row subarea'][./div[contains(text(),'#{subarea}')]]//a[contains(text(),'Delete')]").click
    else
      page.find(:xpath, ".//div[@class='row area panel-heading'][./div[contains(text(),'#{area}')]]").find('.delete_area').click
    end
  end

  def open_subarea_panel_for_area(area)
    page.find(:xpath, ".//div[@class='panel panel-default'][.//div[contains(text(),'#{area}')]]//a[@id='subareas_link']").click
    sleep(0.3)
  end

  def model
    MediaAppearance
  end

  def filesize_selector
    '#media_appearance_filesize'
  end

  def filesize_context
    page.find(filesize_selector)
  end

  def filetypes_context
    page.find(filetypes_selector)
  end

  def filetypes_selector
    '#media_appearance_filetypes'
  end

  def admin_page
    media_appearance_admin_path('en')
  end
end
