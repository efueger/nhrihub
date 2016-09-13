class Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes < AdvisoryCouncilDocument
  ConfigPrefix = 'nhri.advisory_council_minutes'

  default_scope ->{ order(:created_at => :desc) }

  def title
    # in config/locales/models/terms_of_reference_version/en.yml
    self.class.model_name.human(:date => created_at.localtime.to_date.to_s(:default))
  end
end
