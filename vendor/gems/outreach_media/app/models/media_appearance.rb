class MediaAppearance < ActiveRecord::Base
  belongs_to :positivity_rating
  belongs_to :user
  has_many :reminders, :as => :remindable, :dependent => :delete_all
  delegate :text, :rank, :to => :positivity_rating, :prefix => true, :allow_nil => true

  has_many :media_areas, :dependent => :destroy
  has_many :areas, :through => :media_areas


  def as_json(options={})
    super({:except => [:updated_at, :created_at, :positivity_rating_id],
           :methods=> [:date, :metrics, :has_link, :has_scanned_doc, :media_areas, :reminders, :create_reminder_url, :create_note_url]})
  end

  def page_data
    MediaAppearance.all
  end

  def create_note_url
    #Rails.application.routes.url_helpers.outreach_media_media_appearance_notes_path(:en,id)
  end

  def create_reminder_url
    Rails.application.routes.url_helpers.outreach_media_media_appearance_reminders_path(:en,id)
  end

  def namespace
    :outreach_media
  end

  def date
    created_at.to_date.to_s(:default)
  end

  def metrics
    MediaAppearanceMetrics.new(self)
  end

  def has_link
    !url.blank?
  end

  def has_scanned_doc
    !file_id.blank?
  end
end