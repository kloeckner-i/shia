require 'spec_helper'

module Shia
  describe Environment do
    let(:options) { OpenStruct.new }
    let(:environment) { Environment.new(options: options) }

    describe '#production' do
      it 'returns the production environment name' do
        expect(environment.production).to eq('production')
      end
    end

    describe '#name' do
      subject { environment.name }

      context 'using -e' do
        {
          'production' => 'production',
          'api-test' => 'api-test',
          nil => nil
        }.each do |name, safe_name|
          it do
            options.environment = name
            expect(subject).to eq(safe_name)
          end
        end
      end

      context 'using -b' do
        {
          'feature/KCITECH-1/something_nice/@api-test' => 'api-test',
          'feature/KCITECH-1/@api-test/something_nice' => 'api-test',
          'feature/KCITECH-1/api-test/something_nice' => nil,
          nil => nil
        }.each do |name, safe_name|
          it do
            options.branch = name
            expect(subject).to eq(safe_name)
          end
        end
      end

      context '-b and -e used' do
        it 'raises an WrongEnvOptionsError' do
          options.branch = 'tick'
          options.environment = 'tock'
          expect { subject }.to raise_error(Environment::WrongEnvOptionsError)
        end
      end
    end

    describe '#production?' do
      subject { environment.production? }

      context '@name == @production' do
        it do
          options.environment = 'production'
          expect(subject).to be_truthy
        end
      end

      context '@name != @production' do
        it do
          options.environment = 'testi'
          expect(subject).to be_falsey
        end
      end
    end

    describe '#check' do
      subject { environment.check }

      context 'no env name' do
        it 'raises and NoEnvGivenError' do
          expect { subject }.to raise_error(Environment::NoEnvGivenError)
        end
      end

      context 'got an env name' do
        it 'raises no error' do
          options.environment = 'test'
          expect { subject }.to_not raise_error
        end
      end
    end

    describe '#production_alert' do
      subject { environment.production_alert }

      context 'no env name' do
        it 'raises and ProductionEnvError' do
          expect(environment).to receive(:production?).and_return(true)
          expect { subject }.to raise_error(Environment::ProductionEnvError)
        end
      end

      context 'got an env name' do
        it 'raises no error' do
          expect(environment).to receive(:production?).and_return(false)
          expect { subject }.to_not raise_error
        end
      end
    end
  end
end
