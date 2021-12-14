describe Grant do
  context 'validations' do
    context 'dates ordering' do
      context 'with submit_date after submit_end' do
        subject { FactoryBot.build(:grant, submit_start: Time.now, submit_end: 1.day.ago) }

        it 'has expected error' do
          expect(subject).not_to be_valid
          expect(subject.errors.attribute_names).to include(:submit_start)
        end
      end

      context 'with vote_start after vote_end' do
        subject { FactoryBot.build(:grant, vote_start: 1.week.from_now, vote_end: 1.day.from_now) }

        it 'has expected error' do
          expect(subject).not_to be_valid
          expect(subject.errors.attribute_names).to include(:vote_start)
        end
      end

      context 'with meetings after vote_end' do
        subject { FactoryBot.build(:grant, vote_end: 2.months.from_now, meeting_one: 3.months.from_now, meeting_two: 4.months.from_now) }

        it 'has expected error' do
          expect(subject).not_to be_valid
          expect(subject.errors.attribute_names).to include(:meeting_one, :meeting_two)
        end
      end

      context 'with meeting_two after meeting_one' do
        subject { FactoryBot.build(:grant, meeting_one: 3.weeks.from_now, meeting_two: 2.weeks.from_now) }

        it 'has expected error' do
          expect(subject).not_to be_valid
          expect(subject.errors.attribute_names).to include(:meeting_one)
        end
      end
    end
    context 'grant levels csv' do
      context 'valid' do
        subject { FactoryBot.build(:grant, funding_levels_csv: '0,100, 400, 600-800') }

        it 'succeeds' do
          expect(subject).to be_valid
        end
      end
      context 'invalid range' do
        subject { FactoryBot.build(:grant, funding_levels_csv: '0,600-500') }

        it 'has expected error' do
          expect(subject).not_to be_valid
          expect(subject.errors.attribute_names).to include(:funding_levels_csv)
        end
      end
      context 'invalid input' do
        subject { FactoryBot.build(:grant, funding_levels_csv: '0-600-500') }

        it 'has expected error' do
          expect(subject).not_to be_valid
          expect(subject.errors.attribute_names).to include(:funding_levels_csv)
        end
      end
      context 'more invalid input' do
        subject { FactoryBot.build(:grant, funding_levels_csv: '0,5--120') }

        it 'has expected error' do
          expect(subject).not_to be_valid
          expect(subject.errors.attribute_names).to include(:funding_levels_csv)
        end
      end
    end
  end
end
