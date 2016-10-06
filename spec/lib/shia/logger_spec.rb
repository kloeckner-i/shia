require 'spec_helper'

module Shia
  describe Logger do
    describe '.log' do
      it 'sets the correct loglevel' do
        expect(Logger.log.level).to eq(::Logger::INFO)
      end
    end

    %w(info warn error).each do |level|
      describe "##{level}" do
        it 'logs' do
          expect { Logger.log.send(level.to_sym, 'test') }.to_not raise_error
        end
      end
    end
  end
end
