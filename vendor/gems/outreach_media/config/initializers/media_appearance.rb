if Rails.env.development? || Rails.env.test? || Rails.env.jstest?
  factory_path = Rails.root.join('vendor','gems','outreach_media','spec','factories')
  FactoryGirl.definition_file_paths << factory_path
end
