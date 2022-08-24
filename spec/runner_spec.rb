require File.expand_path('../spec_helper', __FILE__)
require 'open3'
require 'shellcheck/runner'

describe Shellcheck::Runner do
  describe '.new' do
    context 'with an argument' do
      it 'sets the argument to binary_path' do
        binary_path = 'foo'
        expect(described_class.new(binary_path).binary_path).to eq binary_path
      end
    end

    context 'without an argument' do
      it 'has default binary_path' do
        expect(described_class.new(nil).binary_path).to eq 'shellcheck'
      end
    end
  end

  describe '#run' do
    context 'without options' do
      it 'executes shellcheck without arguments and return its stdout' do
        stdout = 'foo'
        stderr = ''
        status = instance_double(Process::Status, exitstatus: 0, success?: true)
        allow(Open3).to receive(:capture3).with('shellcheck').once.and_return [stdout, stderr, status]
        expect(described_class.new(nil).run([], {})).to eq stdout
      end
    end

    context 'with options' do
      let!(:options) do
        {
          check_sourced: true,
          color: :auto,
          include: 'a,b',
          exclude: ['c', 'd']
        }
      end

      it 'executes shellcheck with arguments and return its stdout' do
        args = %w[shellcheck --check-sourced --color auto --include a,b --exclude c,d bar]
        stdout = 'foo'
        stderr = ''
        status = instance_double(Process::Status, exitstatus: 0, success?: true)
        allow(Open3).to receive(:capture3).with(*args).once.and_return [stdout, stderr, status]
        expect(described_class.new(nil).run(['bar'], options)).to eq stdout
      end
    end

    context 'when command not found' do
      it 'raises an error' do
        error = Errno::ENOENT.new('No such file or directory - shellcheck')
        allow(Open3).to receive(:capture3).with('shellcheck').once.and_raise error
        expect { described_class.new(nil).run([], {}) }.to raise_error error
      end
    end
  end
end
