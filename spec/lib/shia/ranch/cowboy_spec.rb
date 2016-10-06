require 'spec_helper'

module Shia
  module Ranch
    describe Cowboy do
      let(:options) { OpenStruct.new }
      let(:system_yml) { 'spec/files/ymls/system.yml' }
      subject { Shia::Ranch::Cowboy.new(options) }

      before(:each) do
        ENV['CI_BUILD_REF'] = 'deadbeefdeadbeefdeadbeef'
        ENV['CI_BUILD_REF_NAME'] = 'feature/KCITECH-1/deployment/#api-test'
        sleep_time = ENV['SLEEP_TIME'].to_i || 0
        %w(Project Environment Machine Registry).each do |klass|
          allow_any_instance_of("::Rancher::Api::#{klass}".constantize).to receive(:sleep) { sleep(sleep_time) }
        end
        path = 'spec/files/repos/deployment/test'
        allow_any_instance_of(Repo::Local).to receive(:path).and_return(path)
      end

      describe 'live test' do
        before(:each) do
          options.environment = 'api-test'
          allow_any_instance_of(Repo::Local).to receive(:path).and_return(path)
        end

        xit 'just do it' do
          options.environment = 'api-test'
          subject.deploy_all
        end
      end

      describe '#deploy_all' do
        before(:each) do
          options.environment = 'api-test'
          allow(Shia::Config).to receive(:stacks).and_return(YAML.load(File.read('spec/files/ymls/stacks.yml')))
          allow(Shia::Config).to receive(:docker_registry).and_return(YAML.load(File.read('spec/files/ymls/docker_registry.yml')))
          allow_any_instance_of(Repo::Remote).to receive(:export)
          allow_any_instance_of(Repo::Remote).to receive(:base_path).and_return('spec/files/repos')
        end

        context 'stacks not pre-existing' do
          it 'deploys a new qa environment and de', vcr: true, action: 'deploy_all' do
            options.environment = 'api-test'
            expect_any_instance_of(EnvironmentManager).to receive(:up).and_call_original
            expect_any_instance_of(EnvironmentManager).to receive(:set).and_call_original
            expect_any_instance_of(RegistryManager).to receive(:up).and_call_original
            expect_any_instance_of(MachineManager).to receive(:up)
            allow_any_instance_of(StackManager).to receive(:upsert).and_call_original
            allow_any_instance_of(StackManager).to receive(:create)
            expect { subject.deploy_all }.to_not raise_error
          end
        end
      end

      describe '#teardown' do
        before(:each) do
          options.environment = 'api-test'
        end

        it 'tearsdown the environment', vcr: true, action: 'teardown' do
          expect_any_instance_of(StackManager).to receive(:teardown).and_call_original
          expect_any_instance_of(MachineManager).to receive(:teardown).and_call_original
          expect_any_instance_of(RegistryManager).to receive(:teardown).and_call_original
          expect_any_instance_of(EnvironmentManager).to receive(:teardown).and_call_original
          subject.teardown
        end
      end

      describe '#destroy' do
        before(:each) do
          options.environment = 'api-test'
        end

        it 'destroys the stack', vcr: true, action: 'destroy' do
          subject.destroy
          expect(::Rancher::Api::Environment.all.where(state: 'active').count).to eq(0)
        end
      end

      describe '#ls' do
        context 'no environment given' do
          it 'lists all stacks', vcr: true, action: 'ls' do
            allow_any_instance_of(::Rancher::Api::Project).to receive(:environments).and_return([])
            expect { subject.ls }.to output(/api-test/).to_stdout
            expect { subject.ls }.to output(/production/).to_stdout
            subject.ls
          end
        end

        context 'environment given' do
          before(:each) { options.environment = 'api-test' }

          it 'only lists stacks of the environment', vcr: true, action: 'ls' do
            allow_any_instance_of(::Rancher::Api::Project).to receive(:environments).and_return([])
            expect { subject.ls }.to output(/api-test/).to_stdout
            expect { subject.ls }.to_not output(/production/).to_stdout
          end
        end
      end
    end
  end
end
