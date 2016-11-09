Rails.application.routes.draw do
  scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
    namespace :strategic_plan_reporter do
      # insert your routes here
    end
  end
end
