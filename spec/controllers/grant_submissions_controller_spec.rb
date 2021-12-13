describe GrantSubmissionsController do
  let!(:grant) { FactoryBot.create(:grant) }
  let!(:artist) { FactoryBot.create(:artist, :activated) }
  let!(:grant_submission) { FactoryBot.create(:grant_submission, artist: artist, grant: grant) }

  describe '#destroy' do
    def go!(id)
      delete 'destroy', params: { id: id }
    end

    subject { response }

    context 'artist signed in' do
      before { sign_in artist }

      context 'with valid submission for artist' do
        it 'deletes submission' do
          expect { go! grant_submission.id }.to change { GrantSubmission.count }.by(-1)

          expect(GrantSubmission.where(id: grant_submission.id)).not_to exist

          expect(response).to redirect_to(grant_submissions_path)
        end
      end

      context 'with non-existent grant_submission id' do
        it 'does not delete any submissions' do
          expect { go! GrantSubmission.count + 1 }.not_to change { GrantSubmission.count }
        end
      end

      context 'with grant_submission id for another artist' do
        let!(:another_grant_submission) { FactoryBot.create(:grant_submission) }

        it 'does not delete any submissions' do
          expect { go! another_grant_submission.id }.not_to change { GrantSubmission.count }
        end
      end
    end
  end

  describe '#discuss' do
    def go!(id)
      get 'discuss', params: { id: id }
    end

    subject { response }

    context 'artist signed in' do
      before { sign_in artist }

      context 'with valid submission for artist' do
        render_views

        it 'shows discussion page' do
          go! grant_submission.id
          expect(response).to render_template('grant_submissions/discuss')

          # this is an artist, so we can edit the answers but not questions
          expect(css_select('textarea#grant_submission_questions')).to be_empty

          # answers block is present and not disabled
          expect(css_select('textarea#grant_submission_answers').first.attr('disabled')).to be_nil
        end
      end

      context 'with non-existent grant_submission id' do
        before { go! GrantSubmission.count + 1 }

        it { is_expected.not_to be_ok }
      end

      context 'with grant_submission id for another artist' do
        let!(:another_grant_submission) { FactoryBot.create(:grant_submission) }

        before { go! another_grant_submission.id }

        it { is_expected.not_to be_ok }
      end
    end

    context 'voter signed in' do
      let(:voter) { FactoryBot.create(:voter, :verified, :activated) }

      before { sign_in voter }

      context 'with valid grant_submission' do
        render_views

        it 'is not allowed to see discussion page' do
          # "Discussion" now refers to granting/funding, which is led by the
          # admin, so voters are not allowed.
          go! grant_submission.id
          is_expected.to be_forbidden
        end
      end

      context 'with non-existent grant_submission id' do
        it { go! GrantSubmission.count + 1; expect(response).not_to be_ok }
      end
    end

    context 'admin signed in' do
      let(:admin) { FactoryBot.create(:admin, :activated) }

      before { sign_in admin }

      context 'with valid grant_submission' do
        render_views

        it 'shows discussion page' do
          go!(grant_submission.id)
          expect(response).to render_template('grant_submissions/discuss')

          # questions block is present and not disabled
          expect(css_select('textarea#grant_submission_questions').first.attr('disabled')).to be_nil

          # answers block is not editable
          expect(css_select('textarea#grant_submission_answers')).to be_empty
        end
      end

      context 'with non-existent grant_submission id' do
        it { go! GrantSubmission.count + 1; expect(response).not_to be_ok }
      end
    end
  end
end
