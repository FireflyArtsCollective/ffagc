describe VotersController do
  subject { response }

  describe '#index' do
    def go!
      get 'index'
    end

    it { go!; is_expected.to be_forbidden }

    context 'with admin signed in' do
      let!(:admin) { FactoryBot.create(:admin) }

      before { sign_in admin }

      it { go!; is_expected.to be_ok }
    end
  end

  describe '#new' do
    it 'returns ok' do
      get 'new'
      expect(response).to be_ok
    end
  end

  describe '#show' do
    let!(:voter) { FactoryBot.create(:voter, :activated) }

    def go!(id)
      get :show, params: { id: id }
    end

    context 'with activated voter' do
      before do
        sign_in voter
      end

      it { go! voter.id; is_expected.to be_ok }

      context 'for another voter' do
        let!(:another_voter) { FactoryBot.create(:voter) }

        it { go! another_voter.id; is_expected.to be_forbidden }
      end
    end

    context 'with user who cannot a voter' do
      let!(:user) { FactoryBot.create(:artist) }

      before do
        sign_in user
      end

      it { go! voter.id; is_expected.to be_forbidden }
    end
  end

  describe '#create' do
    let(:voter_attributes) { FactoryBot.attributes_for(:voter) }

    def go!
      post 'create', params:  {
        voter: voter_attributes.merge(voter_survey_attributes: FactoryBot.attributes_for(:voter_survey)),
        grants_voters: {
          0 => "1"
        }
      }
    end

    it 'returns ok' do
      go!
      expect(response).to be_ok
    end

    it 'creates correct Voter' do
      expect { go! }.to change(Voter, :count).by(1)
      # don't include password attributes as those are not stored directly in the db
      expected_attributes = voter_attributes.reject { |k| k.to_s.start_with? 'password' }
      expect(HashWithIndifferentAccess.new(Voter.last.attributes)).to include(expected_attributes)
    end

    it 'creates correct VoterSurvey' do
      expect { go! }.to change(VoterSurvey, :count).by(1)
      voter_survey = VoterSurvey.last
      expect(HashWithIndifferentAccess.new(voter_survey.attributes)).to include(FactoryBot.attributes_for(:voter_survey))
      expect(voter_survey.voter).to eq(Voter.last)
    end

    context 'with existing voter email' do
      let!(:existing_voter) { FactoryBot.create(:voter, :activated) }

      it 'returns an error' do
        post 'create', params: { voter: { email: existing_voter.email } }
        expect(response).to render_template('new')
      end
    end
  end

  describe '#update' do
    let!(:voter) { FactoryBot.create(:voter) }
    let!(:grant_1) { FactoryBot.create(:grant) }
    let!(:grant_2) { FactoryBot.create(:grant) }

    let(:grants_voters_params) do
      {
        grant_1.id => "0",
        grant_2.id => "1"
      }
    end

    def go!
      put 'update', params: { :id => voter.id, :grants_voters => grants_voters_params }
    end

    before do
      sign_in user
    end

    context 'when voter signed in' do
      let!(:user) { FactoryBot.create(:voter) }

      it { go!; is_expected.to be_forbidden }
    end

    context 'when admin logged in' do
      let!(:user) { FactoryBot.create(:admin) }

      it 'creates new grants_voters' do
        go!
        expect(GrantsVoter.where(grant: grant_2, voter: voter)).to exist
      end

      context 'with existing grants_voter' do
        let!(:grants_voter) { FactoryBot.create(:grants_voter, grant_id: 1, voter: voter) }

        it 'deletes' do
          go!
          expect(GrantsVoter.where(id: grants_voter.id)).not_to exist
        end
      end
    end
  end

  describe '#verify' do
    let!(:voter) { FactoryBot.create(:voter) }

    before { sign_in user }

    def go!
      post 'verify', params: { id: voter.id }
    end

    context 'when voter signed in' do
      let!(:user) { voter }

      it { go!; is_expected.to be_forbidden }
    end

    context 'when admin logged in' do
      let!(:user) { FactoryBot.create(:admin) }

      it 'verifies voter' do
        expect { go! }.to change { voter.reload.verified }.to true
      end

      context 'with send_email param' do
        def go!
          post 'verify', params: { id: voter.id, send_email: 'true' }
        end

        it 'verifies voter' do
          expect { go! }.to change { voter.reload.verified }.to true
          expect(flash[:info]).to be_present
        end

        it 'sends email' do
          expect(UserMailer).to receive(:voter_verified)
          go!
        end
      end

      context 'with params verify: 0' do
        def go!
          post 'verify', params: { id: voter.id, verify: '0', send_email: 'true' }
        end

        it 'unverifies voter' do
          expect { go! }.to change { voter.reload.verified }.to false
          expect(flash[:info]).to be_present
        end

        it 'does not send email' do
          go!
          expect(UserMailer).not_to receive(:voter_verified)
        end
      end
    end
  end
end
