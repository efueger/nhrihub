require 'rspec/core/shared_context'

module RegisteredUserHelper
  extend RSpec::Core::SharedContext
  before do
    admin = create_user('admin')
    assign_permissions(admin, 'admin', admin_roles)
    staff = create_user('staff')
    assign_permissions(staff, 'staff', staff_roles)
  end

private
  def create_user(login)
    user = User.create(:login => login,
                :email => Faker::Internet.email,
                :enabled => true,
                :firstName => Faker::Name.first_name,
                :lastName => Faker::Name.last_name,
                :organization => Organization.first)
    user.update_attribute(:salt, '1641b615ad281759adf85cd5fbf17fcb7a3f7e87')
    user.update_attribute(:activation_code, '9bb0db48971821563788e316b1fdd53dd99bc8ff')
    user.update_attribute(:activated_at, DateTime.new(2011,1,1))
    user.update_attribute(:crypted_password, '660030f1be7289571b0467b9195ff39471c60651')
    user
  end

  def assign_permissions(user, role, actions)
    role = Role.create(:name => role)
    Controller.update_table
    actions.each { |a| role.actions << a  }
    user.roles << role
    user.save
  end

  def admin_roles
    Action.all
  end

  def staff_roles
    Action.
      all.
      reject{|a|
        a.controller_name =~ /authengine/ && 
          !(a.controller_name =~ /sessions/ && (a.action_name == "new" || a.action_name == "destroy")) # login/logout
      }.
      reject{|a| a.controller_name =~ /admin/}
  end
end

module LoggedInEnAdminUserHelper
  extend RSpec::Core::SharedContext
  include RegisteredUserHelper
  before do
    visit "/en"
    fill_in "User name", :with => "admin"
    fill_in "Password", :with => "password"
    click_button "Log in..."
  end
end

module LoggedInFrAdminUserHelper
  extend RSpec::Core::SharedContext
  include RegisteredUserHelper
  before do
    visit "/fr"
    fill_in "Nom d'usilateur", :with => "admin"
    fill_in "Mot de pass", :with => "password"
    click_button "S'identifier..."
  end
end
