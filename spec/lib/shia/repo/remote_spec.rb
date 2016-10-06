require 'spec_helper'

module Shia
  module Repo
    describe Remote do
      describe '.all' do
        subject { Remote.all(ignore: OpenStruct.new(group: 'deployment', project: 'shia')) }

        it 'returns all projects except the local one' do
          allow(Shia::Config).to receive(:stacks).and_return(YAML.load(File.read('spec/files/ymls/stacks.yml')))
          subject.each do |project|
            expect(project).to be_instance_of(Remote)
          end
          expect(subject.map(&:name)).to eq(%w(deployment-test))
        end
      end

      let(:repo) { Remote.new(group: 'deployment', project: 'test') }

      describe '#export' do
        it 'uses git archive to get the files' do
          allow(Shia::Config).to receive(:git_config).and_return(YAML.load(File.read('spec/files/ymls/git_config.yml')))
          expect(repo).to receive(:`)
            .with('mkdir -p /tmp/repos/deployment/test && cd /tmp/repos/deployment/test && git archive --remote=git@git.example.com:deployment/test.git master shia | tar xvf -')
          repo.export
        end
      end
    end
  end
end
