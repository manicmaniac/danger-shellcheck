require 'open3'

module Shellcheck
  class Runner
    attr_reader :binary_path

    def initialize(binary_path)
      @binary_path = binary_path || 'shellcheck'
    end

    def run(files, options)
      arguments = arguments_from_options(options) + files
      stdout, stderr, status = Open3.capture3(*arguments)
      raise "error: #{arguments} exited with status code #{status.exitstatus}. #{stderr}" unless status.success?

      stdout
    end

    private

    def arguments_from_options(options)
      options.each_with_object([@binary_path]) do |(key, value), new_options|
        next unless value

        value = nil if value.is_a?(TrueClass)
        value = value.join(',') if value.is_a?(Array)
        new_options << "--#{key.to_s.tr('_', '-')}"
        new_options << value.to_s if value
      end
    end
  end
end
