describe ProposalsController do
  let!(:artist) { FactoryBot.create(:artist, :activated) }
  let!(:grant_submission) { FactoryBot.create(:grant_submission, artist: artist) }
  let!(:proposal) { FactoryBot.create(:proposal, grant_submission: grant_submission) }

  describe '#destroy' do
    def go!(id)
      delete 'destroy', params: { id: id }
    end

    subject { response }

    context 'artist signed in' do
      before { sign_in artist }

      context 'with valid submission for artist' do
        it 'deletes submission' do
          expect { go! proposal.id }.to change { Proposal.count }.by(-1)

          expect(Proposal.where(id: proposal.id)).not_to exist

          expect(response).to redirect_to(edit_grant_submission_path(grant_submission))
        end
      end

      context 'with non-existent proposal id' do
        it 'does not delete any proposals' do
          expect { go! Proposal.count + 1 }.not_to change { Proposal.count }
        end
      end

      context 'with proposal id for another artist' do
        let!(:another_proposal) { FactoryBot.create(:proposal) }

        it 'does not delete any submissions' do
          expect { go! another_proposal.id }.not_to change { Proposal.count }
        end
      end
    end

    context 'voter signed in' do
      let!(:voter) { FactoryBot.create(:voter, :activated) }

      before { sign_in voter }

      context 'with valid submission' do
        it 'deletes submission' do
          expect { go! proposal.id }.not_to change { Proposal.count }
          expect(response).to be_forbidden
        end
      end
    end
  end
end
