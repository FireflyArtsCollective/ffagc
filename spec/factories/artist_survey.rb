FactoryBot.define do
  factory :artist_survey do
    artist
    has_attended_firefly { Faker::Number.between(from: 0, to: 1) }
    has_attended_regional { true }
    has_attended_bm { Faker::Boolean.boolean }
    can_use_as_example { Faker::Boolean.boolean }
    has_attended_firefly_desc { Faker::Lorem.paragraph }
    has_attended_regional_desc { Faker::Lorem.paragraph }
    has_attended_bm_desc { Faker::Lorem.paragraph }
  end
end
