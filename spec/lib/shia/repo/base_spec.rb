require 'spec_helper'

module Shia
  module Repo
    describe Base do
      let(:repo) { Remote.new(group: 'infrastructure', project: 'elk') }

      describe '#check_images' do
        context 'docker_image available' do
          xit 'does not raise an exception', vcr: true do
            repo = Remote.new(group: 'deployment', project: 'test')
            expect(repo).to receive(:commit_hash).and_return('latest').at_least(1)
            expect(repo).to receive(:docker_compose_file).and_return('image: ${IMAGE_NAME}')
            repo.check_images
          end
        end

        context 'tag unavailable' do
          xit 'raises an exception ImageNotAvailbleAtDockerRegistryError', vcr: true do
            repo = Remote.new(group: 'deployment', project: 'test')
            expect(repo).to receive(:commit_hash).and_return('latestest').at_least(1)
            expect(repo).to receive(:docker_compose_file).and_return('image: ${IMAGE_NAME}')
            expect { repo.check_images }.to raise_error(ImageNotAvailbleAtDockerRegistryError)
          end
        end
      end

      describe '#name' do
        {
          { group: 'test', project: 'public_proxy' } => 'test-public-proxy',
          { group: 'test', project: '_:WICKED:_||\/\/clown2' } => 'test-wicked-clown2'
        }.each do |config, safe_name|
          it 'makes the name safe for rancher' do
            repo = Remote.new(config)
            expect(repo.name).to eq(safe_name)
          end
        end

        describe 'when config.name given' do
          let(:config) { OpenStruct.new(group: 'test', project: 'test', name: 'overwrite-name') }

          it 'uses the name from the config' do
            expect(repo).to receive(:config).and_return(config)
            expect(repo.name).to eq('overwrite-name')
          end
        end
      end

      describe '#variable_expansion' do
        context 'ENV[VAR] is set' do
          it 'replaces ${SOMEVAR} with the value of ENV[SOMEVAR]' do
            text = 'I GOT ${MONEY_AND-Stuff}'
            ENV['MONEY_AND-Stuff'] = 'THINGS'
            expect(repo.variable_expansion(text)).to eq('I GOT THINGS')
          end

          it 'replaces $SOMEVAR with the value of ENV[SOMEVAR]' do
            text = 'I GOT $MONEY'
            ENV['MONEY'] = 'things'
            expect(repo.variable_expansion(text)).to eq('I GOT things')
          end

          it 'does not expand $${test}' do
            text = 'i got $${test}'
            expect(repo.variable_expansion(text)).to eq('i got $${test}')
          end
        end

        context 'includes IMAGE_NAME' do
          it 'generates the correct image name' do
            allow(Shia::Config).to receive(:docker_registry).and_return(YAML.load(File.read('spec/files/ymls/docker_registry.yml')))
            expect(repo).to receive(:commit_hash).and_return('test')
            expect(repo.variable_expansion('image: $IMAGE_NAME')).to eq('image: registry.example.com/infrastructure/elk:test')
          end
        end

        context 'ENV[VAR] is not set' do
          it 'replaces ${SOMEVAR} with ' do
            text = 'I GOT ${MONEY}'
            ENV['MONEY'] = nil
            expect { repo.variable_expansion(text) }.to raise_error(UnsupportedEnvVariableFoundError)
          end
        end
      end

      describe '#make_volume_names_safe' do
        let(:repo) { Remote.new(group: 'group', project: 'project') }
        let(:yaml) do
          %(
test:
  labels:
    io.rancher.container.pull_image: always
  tty: true
  image: ubuntu:14.04.3
  volumes:
  - /tmp/test
  - test_test_test:/tmp/test
  - group_project_foo:/tmp/foo
  - /tmp/foo/test:/tmp/foo/test
  stdin_open: true
  volume_driver: convoy-nfs
)
        end
        let(:expected_yaml) do
          %(---
test:
  labels:
    io.rancher.container.pull_image: always
  tty: true
  image: ubuntu:14.04.3
  volumes:
  - group_project_tmp_test:/tmp/test
  - group_project_test_test_test:/tmp/test
  - group_project_foo:/tmp/foo
  - group_project_tmp_foo_test:/tmp/foo/test
  stdin_open: true
  volume_driver: convoy-nfs
)
        end
        it 'makes volume definitions safe for rancher' do
          expect(repo.make_volume_names_safe(yaml)).to eq(expected_yaml)
        end
      end
    end
  end
end
