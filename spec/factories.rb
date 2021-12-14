FactoryBot.define do
  factory :submission_tag do
    tag { nil }
    grant_submissions { nil }
  end
  factory :tag do
    name { "MyString" }
    description { "MyText" }
  end
  sequence :email do |n|
    "email-#{n}@example.com"
  end

  sequence :vote_score do
    Faker::Number.between(from: 0, to: 2)
  end
end
