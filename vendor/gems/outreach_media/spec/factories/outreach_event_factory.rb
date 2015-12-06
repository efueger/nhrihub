FactoryGirl.define do
  factory :outreach_event_document do
    file_id             { SecureRandom.hex(30) }
    filesize            { 10000 + (30000*rand).to_i }
    original_filename   { "#{Faker::Lorem.words(2).join("_")}.pdf" }
    original_type       "application/pdf"

    after(:build) do |oed|
      path = Rails.env.production? ?
        Rails.root.join('..','..','shared') :
        Rails.root.join('tmp')
      FileUtils.touch path.join('uploads','store',oed.file_id) 
    end
  end

  factory :outreach_event do
    impact_rating
    title {Faker::Lorem.sentence(5)}
    participant_count { rand(2000) }

    after(:create) do |oe|
      FactoryGirl.create(:outreach_event_document, :outreach_event_id => oe.id)
    end


    trait :no_f_in_title do
      title Faker::Lorem.sentence(5).gsub(/f/i,"b")
    end

    trait :hr_area do
      after(:create) do |oe|
        oe.areas << Area.where(:name => "Human Rights").first
        oe.save
      end
    end

    trait :si_area do
      after(:create) do |oe|
        oe.areas << Area.where(:name => "Special Investigations Unit").first
        oe.save
      end
    end

    trait :gg_area do
      after(:create) do |oe|
        oe.areas << Area.where(:name => "Good Governance").first
        oe.save
      end
    end

    trait :crc_subarea do
      after(:create) do |oe|
        oe.subareas << Subarea.where(:name => "CRC").first
        oe.save
      end
    end
  end
end