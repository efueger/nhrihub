require_relative './seed_data'

SeedData.initialize


MagicLamp.define do
  # e.g. on page do this:  window.media_appearances = MagicLamp.loadJSON('collection_items')
  fixture(:name => 'collection_items') do
    SeedData.initialize
    MediaAppearance.all
  end

  fixture(:name => 'advisory_council_issues') do
    SeedData.initialize
    Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.all
  end

  fixture(:name => 'areas_data') do
    AreaTest.populate_test_data
    Area.all
  end

  fixture(:name => 'subareas_data') do
    AreaTest.populate_test_data
    Subarea.extended
  end

  fixture(:name => 'new_collection_item') do
    MediaAppearance.new
  end

  fixture(:name => 'new_advisory_council_issue_collection_item') do
    Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.new
  end

  fixture(:name => 'create_collection_item_url') do
    MediaAppearance.new.create_url
  end

  fixture(:name => 'create_advisory_council_issue_collection_item_url') do
    Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.new.create_url
  end

  fixture(:name => 'maximum_filesize') do
    5000000
  end

  fixture(:name => 'permitted_filetypes') do
    ['pdf']
  end

  fixture(:name => 'media_appearance_page') do
    @areas = Area.all
    render :partial => 'media_appearances/index'
  end

  fixture(:name => 'advisory_council_issues_page') do
    render :partial => 'nhri/advisory_council/issues/index'
  end

end
