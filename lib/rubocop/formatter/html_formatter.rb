# encoding: utf-8
require 'erb'
require 'action_view'
require 'action_view/helpers'

module Rubocop
  module Formatter
    class HTMLFormatter < JSONFormatter

      TEMPLATE_PATH = "#{File.dirname(__FILE__)}/templates/report.html.erb"
      SCM_BASE_URL = "http://code.livingsocial.net/dev/babysoft/tree/master"

      def initialize(output)
        super
        @template = ERB.new(File.new(TEMPLATE_PATH).read)
        @app_name = 'Babysoft'
      end

      def finished(inspected_files)
        output_hash[:summary][:inspected_file_count] = inspected_files.count
        output.puts(@template.result(binding))
      end

      def report_file(file, offences)
        super
      end

      def hash_for_location(offence)
        super.merge(
          { 
            source_line: offence.location.source_line, 
            column_pointer: ' ' * offence.location.column + '^' * offence.location.column_range.count 
          }
        )
      end

      def offence_file_path(path, line)
        "#{SCM_BASE_URL}/#{path}#L#{line}"
      end

      def offence_group_name(file)
        file[:path].gsub(/\/|\./, '-')
      end

      def file_summary(file)
        offences = file[:offences]
        offence_count = offences.size
        severity_counts = offences.group_by{|off| off[:severity]}.map{|k,v| "#{k}: #{v.size}"}.join(', ')
        "#{file[:path]}  <span class='filepath-totals'>Total offences: #{offence_count} | #{severity_counts}</span>"
      end

      def debug(object)
        Marshal::dump(object)
        object = ERB::Util.html_escape(object.to_yaml).gsub(" ", "&nbsp; ").html_safe
        "<pre class='debug_dump'>#{object}</pre>"
      end

    end
  end
end
