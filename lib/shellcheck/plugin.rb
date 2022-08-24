require 'set'
require 'shellcheck/runner'

module Danger
  # Shows the warnings and suggestions for shell scripts generated from ShellCheck.
  # You need [ShellCheck](https://github.com/koalaman/shellcheck) installed and generating a json file
  # to use this plugin.
  #
  # @example Showing summary
  #
  #     shellcheck -f json myscript > shellcheck.json
  #     shellcheck.report 'shellcheck.json'
  #
  # @see IntrepidPursuits/danger-shellcheck
  # @tags bash, sh, lint, syntax, format, analysis
  #
  class DangerShellcheck < Plugin
    # The project root, which will be used to make the paths relative.
    # Defaults to 'pwd'.
    # @return   [String] project_root value
    attr_accessor :project_root

    # Defines if the test summary will be sticky or not
    # Defaults to 'false'
    # @return   [Boolean] sticky
    attr_accessor :sticky_summary

    attr_accessor :binary_path

    OPTION_OVERRIDES = {
      format: :json
    }.freeze

    def project_root
      root = @project_root || Dir.pwd
      root += '/' unless root.end_with? '/'
      root
    end

    def sticky_summary
      @sticky_summary || false
    end

    # Reads a file with JSON ShellCheck summary and reports it.
    #
    # @param    [String] file_path Path for ShellCheck summary in JSON format.
    # @return   [void]
    def report(file_path)
      raise 'ShellCheck summary file not found' unless File.file?(file_path)
      shellcheck_summary = JSON.parse(File.read(file_path), symbolize_names: true)
      run_summary(shellcheck_summary)
    end

    def run(options = {})
      runner = Shellcheck::Runner.new(binary_path)
      changed_files = files_in_diff
      return if changed_files.empty?
      out = runner.run(changed_files, options.merge(OPTION_OVERRIDES))
      shellcheck_summary = JSON.parse(out, symbolize_names: true)
      run_summary(shellcheck_summary)
    end

    private

    def run_summary(shellcheck_summary)
      @files = Set.new
      @error_count = 0
      @warning_count = 0
      @info_count = 0
      @style_count = 0

      # Parse the file violations
      parse_files(shellcheck_summary)

      # Output the ShellCheck summary
      message(summary_message, sticky: sticky_summary)
    end

    def summary_message
      "ShellCheck Summary: Analyzed #{@files.size} files. Found #{@error_count} errors. #{@warning_count} Warnings, #{@info_count} Info and #{@style_count} Style Violations."
    end

    # A method that takes the ShellCheck summary and parses any violations found
    def parse_files(shellcheck_summary)
      shellcheck_summary.each do |element|
        file = element[:file]
        @files.add(file)
        level = element[:level]

        message = format_violation(file, element)

        if level == 'error'
          @error_count += 1
          fail(message, sticky: false)
        else
          if level == 'warning'
            @warning_count += 1
          elsif level == 'info'
            @info_count += 1
          else
            @style_count += 1
          end
          warn(message, sticky: false)
        end
      end
    end

    # A method that returns a formatted string for a violation
    # @return   String
    #
    def format_violation(file, violation)
      "#{file}: #L#{violation[:line]} -> #{violation[:code]} - #{violation[:message]}"
    end

    def files_in_diff
      # Taken from https://github.com/ashfurrow/danger-ruby-swiftlint/blob/5184909aab00f12954088684bbf2ce5627e08ed6/lib/danger_plugin.rb#L214-L216
      renamed_files_hash = git.renamed_files.to_h { |rename| [rename[:before], rename[:after]] }
      post_rename_modified_files = git.modified_files.map do |modified_file|
        renamed_files_hash[modified_file] || modified_file
      end
      (post_rename_modified_files - git.deleted_files) + git.added_files
    end
  end
end
