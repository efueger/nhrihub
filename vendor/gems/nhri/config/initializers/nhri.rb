# also needed in production just to support creating fake
# InternalDocument records during development with a rake task
factory_path = Rails.root.join('vendor','gems','nhri','spec','factories')
FactoryGirl.definition_file_paths << factory_path
