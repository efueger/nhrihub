class Nhri::TextMonitor < ActiveRecord::Base
  PermittedAttributes = [:description, :date, :indicator_id]
  belongs_to :indicator
  belongs_to :author, :class_name => "User", :foreign_key => :author_id

  default_scope ->{ order(:date => :asc, :created_at => :asc) }

  def as_json(options={})
    super(:except => [:updated_at, :created_at], :methods => [:url, :description, :author, :formatted_date])
  end

  def formatted_date
    date.localtime.to_date.to_s(:short)
  end

  def url
    Rails.application.routes.url_helpers.nhri_indicator_monitor_path(:en,indicator.heading_id,indicator_id,id) if persisted?
  end
end
