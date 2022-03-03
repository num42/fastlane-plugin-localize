require "fastlane_core/ui/ui"

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class LocalizeHelper
      # class methods that you define here become available in your action
      # as `Helper::LocalizeHelper.your_method`
      #

      def self.getProjectPath(options)
        projectPath = nil

        unless options.nil?
          projectPath = options[:localize_project]
        end

        if projectPath.nil?
          projectPath = ENV["PROJECT_FILE_PATH"]
        end

        if projectPath.nil?
          projectPath = Dir.entries(".").select { |f| f.end_with?(".xcodeproj") }.first
        end

        if projectPath.nil?
          fail "no xcodeproject found"
        end

        projectPath
      end

      def self.getProject(options)
        project = Xcodeproj::Project.open(self.getProjectPath(options))

        project
      end

      def self.getTargetName(options)
        project = self.getProject(options)

        targetName = nil

        unless options.nil?
          targetName = options[:localize_target]
        end

        if targetName.nil?
          targetName = ENV["TARGET_NAME"]
        end

        if targetName.nil?
          targetName = project.targets.map { |target| target.name.to_s }.first
        end

        if targetName.nil?
          fail "no target found"
        end

        targetName
      end

      def self.getTarget(options)
        project = self.getProject(options)
        targetName = self.getTargetName(options)

        target = project.targets.select { |target| target.name.eql? targetName }.first

        if target.nil?
          fail "no target"
        end

        target
      end

      def self.codeFiles(target, options)
        if options[:file_filter].nil?
          filter = []
        else
          filter = (options[:file_filter]).split(",")
        end

        codeFiles = target.source_build_phase.files.to_a.map do |pbx_build_file|
          pbx_build_file.file_ref.real_path.to_s
        end.select do |path|
          path.end_with?(".swift")
        end.select do |path|
          bool = true

          filter.each { |filter|
            if path.include? filter
              bool = false
            end
          }

          next bool
        end.select do |path|
          File.exists?(path)
        end

        codeFiles
      end

      def self.stringsFromFile(file)
        strings = File.readlines(file).to_s.enum_for(:scan,
                                                     /(?<!\#imageLiteral\(resourceName:|\#imageLiteral\(resourceName: |NSLocalizedString\()\\"[^\\"\r\n]*\\"/).flat_map { Regexp.last_match }
        return strings
      end

      def self.showStringOccurrencesFromFile(file, string)
        line_array = File.readlines(file)

        File.open(file).each_with_index { |line, index|
          if line =~ /(?<!\#imageLiteral\(resourceName:|\#imageLiteral\(resourceName: |NSLocalizedString\()#{Regexp.escape(string)}/
            hits = line_array[index - 2..index - 1] + [line_array[index].green] + line_array[index + 1..index + 2]
            UI.message "In file #{file} (line #{index}): \n\n#{hits.join()}"
          end
        }
      end

      def self.whitelistFilename
        "fastlane/.fastlane_localization_whitelist"
      end

      def self.addToWhitelist(string)
        open(whitelistFilename, "a") { |f|
          f.puts string
        }
        UI.message "Added \"#{string}\" to #{whitelistFilename}"
      end

      def self.getWhitelist
        if File.exist?(whitelistFilename)
          return File.readlines(whitelistFilename).map(&:strip).map { |s| s.gsub(/^\\"/, "\"").gsub(/\\"$/, "\"") }
        else
          return []
        end
      end

      def self.localize_string(string, key, files, params)
        open(params[:strings_file], "a") { |f|
          f.puts "\"#{key}\" = #{string};"
        }
        files.each do |file_name|
          text = File.read(file_name)

          new_contents = text.gsub(string, replacementString(key, params))

          File.open(file_name, "w") { |file| file.puts new_contents }
        end

        UI.message "Replaced \"#{string}\" with \"#{replacementString(key, params)}\""
      end

      def self.replacementString(key, params)
        if params[:use_swiftgen]
          return "L10n.#{key.gsub(".", "_").split("_").inject { |m, p| m + p.capitalize }}"
        else
          return "NSLocalizedString(\"#{key}\")"
        end
      end
    end
  end
end
