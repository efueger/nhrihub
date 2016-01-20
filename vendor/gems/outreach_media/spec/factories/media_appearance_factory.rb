violation_severities = ViolationSeverity.pluck(:id)
performance_indicator_ids = PerformanceIndicator.pluck(:id)

FactoryGirl.define do
  factory :media_appearance do
    user
    positivity_rating
    title {Faker::Lorem.sentence(5)}

    trait :link do
      #article_link { Faker::Internet.url }
      article_link { "http://www.nytimes.com" } # so we can actually test it!
    end

    trait :file do
      file_id             { SecureRandom.hex(30) }
      filesize            { 10000 + (30000*rand).to_i }
      original_filename   { "#{Faker::Lorem.words(2).join("_")}.pdf" }
      original_type       "application/pdf"
    end

    after(:build) do |media_appearance|
      media_appearance.performance_indicator_ids = performance_indicator_ids.sample(rand(2))
      if media_appearance.file_id
        path = Rails.env.production? ?
          Rails.root.join('..','..','shared') :
          Rails.root.join('tmp')
        FileUtils.touch path.join('uploads','store',media_appearance.file_id) 
      end
    end

    trait :no_f_in_title do
      title Faker::Lorem.sentence(5).gsub(/f/i,"b")
    end

    trait :title_has_an_f do
      str = Faker::Lorem.sentence(5)
      i = rand(str.length)
      l = str.length
      title { new_str = (str.dup.slice(0,i-1)+'f'+str.dup.slice(i-l,1000)).dup }
    end

    trait :hr_area do
      after(:build) do |ma|
        hr_area = Area.where(:name => "Human Rights").first
        ma.areas << hr_area
        subareas = Subarea.where(:area_id => hr_area.id).where.not(:name => "Violation")
        ma.subareas = subareas.sample(rand(6))
      end
    end

    trait :si_area do
      after(:build) do |ma|
        ma.areas << Area.where(:name => "Special Investigations Unit").first
      end
    end

    trait :gg_area do
      after(:build) do |ma|
        ma.areas << Area.where(:name => "Good Governance").first
      end
    end

    trait :crc_subarea do
      after(:build) do |ma|
        ma.subareas << Subarea.where(:name => "CRC").first
      end
    end

    trait :with_notes do
      after(:create) do |oe|
        rand(3).times do
          FactoryGirl.create(:note, :outreach_event, :notable_id => oe.id)
        end
      end
    end

    trait :with_reminders do
      after(:create) do |oe|
        rand(3).times do
          FactoryGirl.create(:reminder, :outreach_event, :remindable_id => oe.id)
        end
      end
    end

    trait :hr_violation_subarea do
      after(:build) do |ma|
        hr_area = Area.where(:name => "Human Rights").first
        ma.areas << hr_area
        ma.subareas << Subarea.where(:name => "Violation", :area_id => hr_area.id).first
        ma.affected_people_count = rand(9000)
        ma.violation_severity_id = violation_severities.sample
      end
    end
  end
end
