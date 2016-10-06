require 'spec_helper'

module Shia
  describe Options do
    describe '#parse' do
      context 'empty args' do
        subject { Options.parse([]) }

        it 'returns the default options' do
          expect(subject.commands).to eq([])
          expect(subject.verbose).to eq(false)
        end
      end

      context 'commands given' do
        subject { Options.parse(%w(deploy -e foobar ls)) }

        it 'returns the options' do
          expect(subject.commands).to eq(%w(deploy ls))
          expect(subject.environment).to eq('foobar')
          expect(Logger.log.level).to eq(::Logger::INFO)
        end
      end

      context '-v' do
        subject { Options.parse(['-v']) }

        it 'sets the log level' do
          subject
          expect(Logger.log.level).to eq(::Logger::DEBUG)
        end
      end

      context '--help' do
        it 'displays help' do
          expect(STDOUT).to receive(:puts)
          expect { Options.parse(%w(-h)) }.to raise_error(SystemExit)
        end
      end

      context '--version' do
        it 'displays the version' do
          expect(STDOUT).to receive(:puts).with(Shia::VERSION)
          expect { Options.parse(%w(--version)) }.to raise_error(SystemExit)
        end
      end
    end
  end
end
