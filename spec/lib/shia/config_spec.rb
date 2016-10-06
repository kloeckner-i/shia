require 'spec_helper'

module Shia
  describe Config do
    describe '.secrets' do
      context 'no secrets file' do
        it 'returns an empty array' do
          expect(File).to receive(:exist?).and_return(false)
          expect(Shia::Config.secrets).to eq({})
        end
      end

      context 'with secrets file' do
        it 'reads the secrets file' do
          expect(Shia::Config).to receive(:secrets_file).and_return('spec/files/ymls/secrets.yml')
          expect(Shia::Config.secrets).to include('RANCHER_URL')
        end
      end
    end
  end
end
