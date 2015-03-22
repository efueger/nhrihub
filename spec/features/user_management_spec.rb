require "rails_helper"
require File.expand_path('../../helpers/login_helpers',__FILE__)
require File.expand_path('../../helpers/navigation_helpers',__FILE__)

feature "User management" do
  include LoggedInAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  before do
    toggle_navigation_dropdown("Admin")
    select_dropdown_menu_item("User management")
  end

  scenario "navigate to user manaagement page" do
    expect(page_heading).to eq "User management"
    expect(page_title).to eq "User management"
  end

  scenario "add a new user" do
    click_link('New User')
    expect(page_heading).to eq "Create a new user account"
    expect(page_title).to eq "Create a new user account"
    fill_in("First name", :with => "Norman")
    fill_in("Last name", :with => "Normal")
    fill_in("Email", :with => "norm@normco.com")
    expect{click_button("Save")}.to change { ActionMailer::Base.deliveries.count }.by(1)
    expect(page_heading).to eq "User management"
    email = ActionMailer::Base.deliveries.last
    expect( email.subject ).to eq "Please activate your Ombudsman M & E database account"
    expect( email.to.first ).to eq "norm@normco.com"
    lines = Nokogiri::HTML(email.body.to_s).xpath(".//p").map(&:text)
    expect( lines[0] ).to eq "Norman Normal"
    expect( lines[1] ).to match "Ombudsman M & E database"
    url = Nokogiri::HTML(email.body.to_s).xpath(".//p/a").attr('href').value
    expect( url ).to match (/\/en\/authengine\/activate\/[\d|a|b|c|d|e|f]{40}$/)
    expect( url ).to match (/^http:\/\/www\.ombudsman\.gov\.ws/)
    # check email was sent, confirm subject and text
  end
end
