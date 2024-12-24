FactoryBot.define do
  factory :voter_survey do
    has_attended_firefly { Faker::Boolean.boolean }
    not_applying_this_year { Faker::Boolean.boolean }
    will_read { Faker::Boolean.boolean }
    will_meet { Faker::Boolean.boolean }
    has_been_voter { Faker::Boolean.boolean }
    has_participated_other { Faker::Boolean.boolean }
    has_received_grant { Faker::Boolean.boolean }
    has_received_other_grant { Faker::Boolean.boolean }
    how_many_fireflies { Faker::Number.between(from: 1, to: 20) }
    signed_agreement { Faker::Boolean.boolean }
    voter
  end
end
