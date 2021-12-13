describe ArtistsController do
  subject { response }

  describe '#index' do
    def go!
      get :index
    end

    it { go!; is_expected.to be_forbidden }

    context 'when admin signed in' do
      let!(:admin) { FactoryBot.create(:admin) }

      before do
        sign_in admin
      end

      it 'is ok' do
        go!
        expect(response).to render_template('index')
        expect(response).to be_ok
      end
    end
  end

  describe '#new' do
    def go!
      get :new
    end

    before { go! }

    it { is_expected.to render_template('new') }
    it { is_expected.to be_ok }
  end

  describe '#create' do
    def go!
      post :create, params: artist_params
    end

    let(:artist_attributes) { FactoryBot.attributes_for(:artist) }
    let(:artist_survey_attributes) { FactoryBot.attributes_for(:artist_survey) }
    let(:artist_params) do
      {
        artist: artist_attributes.merge(artist_survey_attributes: artist_survey_attributes)
      }
    end

    it 'creates Artist' do
      expect { go! }.to change { Artist.count }.by(1)
    end

    it 'creates ArtistSurvey' do
      expect { go! }.to change { ArtistSurvey.count }.by(1)
    end

    it 'sends email' do
      expect(UserMailer).to receive(:account_activation)
      go!
    end

    context 'with invalid params' do
      let(:artist_attributes) { FactoryBot.attributes_for(:artist, email: '') }

      it 'displays form' do
        expect { go! }.not_to change { Admin.count }
        expect(response).to render_template('new')
      end
    end
  end
end
