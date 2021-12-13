describe AdminsController do
  subject { response }

  describe '#index' do
    def go!
      get :index
    end

    context 'with valid params' do
      it 'is ok' do
        go!
        expect(response).to render_template('index')
        expect(response).to be_ok
      end

      context 'when an Admin already exists' do
        let!(:admin) { FactoryBot.create(:admin) }

        it { go!; is_expected.to be_forbidden}

        context 'when admin signed in' do
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
    end
  end

  describe '#new' do
    def go!
      get :new
    end

    before { go! }

    it { is_expected.to render_template('new') }
  end

  describe '#create' do
    def go!
      post :create, params: { admin: admin_params }
    end

    let(:admin_params) { FactoryBot.attributes_for(:admin) }

    it 'creates Admin' do
      expect { go! }.to change { Admin.count }.by(1)
      expect(flash[:success]).to be_present
      expect(response).to redirect_to(root_path)
    end

    context 'when an Admin already exists' do
      let!(:admin) { FactoryBot.create(:admin) }

      it { go!; is_expected.to be_forbidden }

      context 'when admin signed in' do
        before do
          sign_in admin
        end

        it 'creates Admin' do
          expect { go! }.to change { Admin.count }.by(1)
          expect(response).to render_template('new')
          expect(flash.keys).to include('success')
        end
      end
    end

    context 'with invalid params' do
      let(:admin_params) { FactoryBot.attributes_for(:admin, email: nil) }

      it 'displays form' do
        expect { go! }.not_to change { Admin.count }
        expect(response).to render_template('new')
      end
    end
  end
end
