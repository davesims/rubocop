# encoding: utf-8
require 'erb'

module Rubocop
  module Formatter
    # A basic formatter that displays only files with offences.
    # Offences are displayed at compact form - just the
    # location of the problem and the associated message.
    class HTMLFormatter < BaseFormatter
      def started(target_files)
        @total_offence_count = 0
        @file_reports = {}
      end

      def file_finished(file, offences)
        return if offences.empty?
        @total_offence_count += offences.count
        report_file(file, offences)
      end

      def finished(inspected_files)
        report_summary(inspected_files.count, @total_offence_count)
      end

      def report_file(file, offences)
        @file_reports[smart_path(file)] = offences
      end

      def report_summary(file_count, offence_count)
        @summary = ''

        plural = file_count == 0 || file_count > 1 ? 's' : ''
        @summary << "#{file_count} file#{plural} inspected, "

        offences_string = case offence_count
                          when 0 then 'no offences'
                          when 1 then '1 offence'
                          else "#{offence_count} offences"
                          end
        @summary << "#{offences_string} detected"

        output.puts ERB.new(File.new("#{File.dirname(__FILE__)}/templates/report.html.erb").read).result(binding)

      end

      protected

      def smart_path(path)
        if path.start_with?(Dir.pwd)
          Pathname.new(path).relative_path_from(Pathname.getwd).to_s
        else
          path
        end
      end
    end
  end
end
