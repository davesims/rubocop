# encoding: utf-8
require 'erb'
require 'action_view'

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

      def offence_file_path(path, line)
        "#{SCM_BASE_URL}/#{path}#L#{line}"
      end

      def file_summary(file)
        offences = file[:offences]
        offence_count = offences.size
        severity_counts = offences.group_by{|off| off[:severity]}.map{|k,v| "#{k}: #{v.size}"}.join(', ')
        "#{file[:path]}  <span class='filepath-totals'>Total offences: #{offence_count} | #{severity_counts}</span>"
      end
    end

  end
end
