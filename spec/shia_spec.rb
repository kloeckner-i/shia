require 'spec_helper'

describe Shia do
  it 'has a version number' do
    expect(Shia::VERSION).not_to be nil
  end

  describe '#run' do
    context 'commands empty' do
      it 'displays a help message' do
        expect(Shia::Logger.log).to receive(:info).with('run with --help to get usage information')
        Shia.run([])
      end
    end

    %w(ls deploy destroy teardown).each do |command|
      context "with command '#{command}'" do
        it 'lets the cowboy handle it' do
          cowboy = double
          expect(Shia::Ranch::Cowboy).to receive(:new).and_return(cowboy)
          expect(cowboy).to receive(command.to_sym)
          Shia.run([command])
        end
      end
    end
  end
end
