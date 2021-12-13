describe PasswordResetsController do
  let!(:artist) { FactoryBot.create(:artist, :activated) }
  let!(:inactive_artist) { FactoryBot.create(:artist) }

  before do
    artist.create_reset_digest
    inactive_artist.create_reset_digest
  end

  describe '#new' do
    it 'renders expected template' do
      get 'new', params: { type: 'artists' }
      expect(response).to render_template('password_resets/new')
    end
  end

  describe '#create' do
    context 'with missing email' do
      it 'shows a flash' do
        post 'create', params: { password_reset: { email: '', type: 'artists' }}
        expect(flash).not_to be_empty
        expect(response).to render_template('password_resets/failure')
      end
    end

    context 'with valid email' do
      def go!
        post 'create', params: { password_reset: { email: artist.email, type: 'artists' }}
      end

      it 'changes the reset digest' do
        expect { go! }.to change { artist.reload.reset_digest }
      end

      it 'sends an email' do
        expect { go! }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end

      it 'shows a flash on expected template' do
        go!
        expect(flash).not_to be_empty
        expect(response).to render_template('password_resets/sent')
      end
    end
  end

  describe '#edit' do
    render_views

    it 'shows password edit' do
      get 'edit', params: { id: artist.reset_token, email: artist.email, type: 'artists' }
      expect(response).to render_template('password_resets/edit')
      assert_select 'input[name=email][type=hidden][value=?]', artist.email
    end

    context 'with incorrect reset_token' do
      it 'shows failure' do
        get 'edit', params: { id: 'wrong token', email: artist.email, type: 'artists' }
        expect(response).to render_template('password_resets/failure')
      end
    end

    context 'with inactive artist' do
      it 'does not allow editing' do
        get 'edit', params: { id: inactive_artist.reset_token, email: inactive_artist.email, type: 'artists' }
        expect(response).to render_template('password_resets/failure')
      end
    end
  end

  describe '#update' do
    def go!
      patch 'update', params: {
            id: artist.reset_token,
            email: artist.email,
            type: 'artists',
            artist: {
              password: password,
              password_confirmation: password_confirmation
            }
      }
    end

    context 'with matching password and password_confirmation' do
      let(:password) { 'foobaz' }
      let(:password_confirmation) { 'foobaz' }

      it 'allows editing the password' do
        expect { go! }.to change { artist.reload.password_digest }
        expect(flash).to be_empty
        expect(response).to render_template('password_resets/success')
      end
    end

    context 'incorrect password_confirmation' do
      let(:password) { 'foobaz' }
      let(:password_confirmation) { 'barbar' }

      it 'shows edit page again' do
        expect { go! }.not_to change { artist.reload.password_digest }
        expect(flash).not_to be_empty
        expect(response).to render_template('password_resets/edit')
      end
    end

    context 'empty password' do
      let(:password) { '' }
      let(:password_confirmation) { '' }

      it 'shows edit page again' do
        expect { go! }.not_to change { artist.reload.password_digest }
        expect(flash).not_to be_empty
        expect(response).to render_template('password_resets/edit')
      end
    end
  end
end
