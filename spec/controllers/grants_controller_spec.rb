describe GrantsController do
  subject { response }

  before do
    sign_in user
  end

  describe '#index' do
    def go!
      get 'index'
    end

    before { go! }

    context 'with an admin' do
      let!(:user) { FactoryBot.create(:admin) }
      it { is_expected.to be_ok }
    end

    context 'with an artist' do
      let!(:user) { FactoryBot.create(:artist, :activated) }
      it { is_expected.to be_ok }
    end

    context 'with a voter' do
      let!(:user) { FactoryBot.create(:voter, :activated) }
      it { is_expected.to be_ok }
    end
  end

  describe '#new' do
    def go!
      get 'new'
    end

    before { go! }

    context 'with an admin' do
      let!(:user) { FactoryBot.create(:admin) }
      it { is_expected.to be_ok }
    end

    context 'with an artist' do
      let!(:user) { FactoryBot.create(:artist, :activated) }
      it { is_expected.to be_forbidden }
    end

    context 'with a voter' do
      let!(:user) { FactoryBot.create(:voter, :activated) }
      it { is_expected.to be_forbidden }
    end
  end

  describe '#create' do
    let(:resource_params) { FactoryBot.attributes_for(:grant) }

    def go!
      post 'create', params: { grant: resource_params }
    end

    before { go! }

    context 'with an admin' do
      let!(:user) { FactoryBot.create(:admin) }
      it { is_expected.to redirect_to(grants_path) }
    end

    context 'with an artist' do
      let!(:user) { FactoryBot.create(:artist, :activated) }
      it { is_expected.to be_forbidden }
    end

    context 'with a voter' do
      let!(:user) { FactoryBot.create(:voter, :activated) }
      it { is_expected.to be_forbidden }
    end
  end

  describe '#edit' do
    let!(:grant) { FactoryBot.create(:grant) }

    def go!
      get 'edit', params: { id: grant.id }
    end

    before { go! }

    context 'with an admin' do
      let!(:user) { FactoryBot.create(:admin) }
      it { is_expected.to render_template('new') }

      context 'with id that does not exist' do
        def go!
          get 'edit', params: { id: Grant.count + 1 }
        end

        it { is_expected.to be_forbidden }
      end
    end

    context 'with an artist' do
      let!(:user) { FactoryBot.create(:artist, :activated) }
      it { is_expected.to be_forbidden }
    end

    context 'with a voter' do
      let!(:user) { FactoryBot.create(:voter, :activated) }
      it { is_expected.to be_forbidden }
    end
  end

  describe '#update' do
    let!(:grant) { FactoryBot.create(:grant) }
    let(:resource_params) do
      {
        name: 'Creativity'
      }
    end

    def go!
      post 'update', params: { id: grant.id, grant: resource_params }
    end

    before { go! }

    context 'with an admin' do
      let!(:user) { FactoryBot.create(:admin) }

      it 'updates grant' do
        expect(grant.reload.name).to eq(resource_params[:name])
      end

      it { is_expected.to redirect_to(grants_path) }

      context 'with invalid update' do
        let(:resource_params) do
          {
            meeting_one: 1.week.ago,
            meeting_two: 2.weeks.ago
          }
        end

        it { is_expected.to render_template('grants/failure') }
      end
    end

    context 'with an artist' do
      let!(:user) { FactoryBot.create(:artist, :activated) }
      it { is_expected.to be_forbidden }
    end

    context 'with a voter' do
      let!(:user) { FactoryBot.create(:voter, :activated) }
      it { is_expected.to be_forbidden }
    end
  end
end
