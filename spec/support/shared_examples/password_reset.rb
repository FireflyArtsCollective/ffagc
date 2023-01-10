shared_examples 'password reset model' do |mailer_method|
  describe '#create_reset_digest' do
    its(:reset_token) { is_expected.to be_nil }
    its(:reset_digest) { is_expected.to be_nil }
    its(:reset_sent_at) { is_expected.to be_nil }

    it 'creates reset_digest' do
      Timecop.freeze do
        subject.create_reset_digest

        expect(subject.reset_token).not_to be_nil
        expect(subject.reset_digest).not_to be_nil
        expect(subject.reset_sent_at).to be_within(1.second).of(Time.now)
      end
    end
  end

  describe '#send_password_reset_email' do
    before { subject.create_reset_digest }

    it 'sents email' do
      expect(UserMailer).to receive(:password_reset).with(mailer_method, subject).and_call_original

      subject.send_password_reset_email
    end
  end

  describe '#password_reset_expired?' do
    before { subject.create_reset_digest }

    its(:password_reset_expired?) { is_expected.to be(false) }

    context 'after 3 hours' do
      it do
        Timecop.travel(3.hours.from_now) do
          expect(subject.password_reset_expired?).to be(true)
        end
      end
    end
  end
end
