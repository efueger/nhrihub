require_relative './area_test'
require_relative './media_appearance_test'
require_relative './outreach_event_test'
require_relative './audience_type_test'
require_relative './impact_rating_test'
class SeedData
  def self.initialize
    AudienceTypeTest.populate_test_data
    AreaTest.populate_test_data
    MediaAppearanceTest.populate_test_data
    ImpactRatingTest.populate_test_data
    OutreachEventTest.populate_test_data
  end
end