describe AccountActivationsController do
  describe '#show' do
    context 'with inactive user' do
      let(:artist) { FactoryBot.create(:artist) }

      context 'with correct token' do
        def go!
          get 'show', params: { type: 'artists', id: artist.activation_token, email: artist.email }
        end

        it 'activates user' do
          expect { go! }.to change { artist.reload.activated? }.from(false).to(true)
        end
      end

      context 'with incorrect token' do
        def go!
          get 'show', params: { type: 'artists', id: 'incorrect_token', email: artist.email }
        end

        it 'does not activate' do
          expect { go! }.not_to change { artist.reload.activated? }
        end
      end
    end

    context 'with activated user' do
      let(:artist) { FactoryBot.create(:artist, :activated) }

      context 'with correct token' do
        def go!
          get 'show', params: { type: 'artists', id: artist.activation_token, email: artist.email }
        end

        it do
          expect { go! }.not_to change { artist.reload.activated }.from(true)
        end
      end

      context 'with incorrect token' do
        def go!
          get 'show', params: { type: 'artists', id: 'incorrect_token', email: artist.email }
        end

        it do
          expect { go! }.not_to change { artist.reload.activated }.from(true)
        end
      end

      context 'when already logged in as that user' do
        def go!
          get 'show', params: { type: 'artists', id: artist.activation_token, email: artist.email }
        end

        before { sign_in artist }

        it 'redirects to root' do
          go!
          expect(flash[:info]).to be_present
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context 'with incorrect email' do
      let(:artist) { FactoryBot.create(:artist) }

      context 'with incorrect email' do
        it 'shows failure' do
          get 'show', params: { type: 'artists', id: artist.activation_token, email: 'test@example.com' }
          expect(response).to render_template('show')
        end
      end
    end
  end

  describe '#create' do
    subject { response }

    def go!
      put 'create'
    end

    shared_examples 'sends new activation token' do
      it 'creates new activation_digest' do
        expect { go! }.to change { user.reload.activation_digest }
      end

      it 'sends email' do
        expect(UserMailer).to receive(:account_activation)
        go!
      end
    end

    shared_examples 'shows already activated message' do
      it 'shows flash' do
        go!
        expect(flash[:info]).to be_present
        expect(response).to redirect_to root_path
      end
    end

    context 'when not logged in' do
      it { go!; is_expected.to be_forbidden }
    end

    context 'when artist signed in' do
      let(:user) { FactoryBot.create(:artist) }

      before { sign_in user }

      context 'with inactive user' do
        it_behaves_like 'sends new activation token'
      end

      context 'with activated user' do
        let(:user) { FactoryBot.create(:artist, :activated) }

        it_behaves_like 'shows already activated message'
      end
    end

    context 'when voter signed in' do
      let(:user) { FactoryBot.create(:voter) }

      before { sign_in user }

      context 'with inactive user' do
        it_behaves_like 'sends new activation token'
      end

      context 'with activated user' do
        let(:user) { FactoryBot.create(:artist, :activated) }

        it_behaves_like 'shows already activated message'
      end
    end
  end
end
