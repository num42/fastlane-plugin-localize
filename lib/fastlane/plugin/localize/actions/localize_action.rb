require 'fastlane/action'
require_relative '../helper/localize_helper'

module Fastlane
  module Actions
    class LocalizeAction < Action
      def self.run(params)
        project = Helper::LocalizeHelper.getProject(params)
        target = Helper::LocalizeHelper.getTarget(project)

        files = Helper::LocalizeHelper.codeFiles(target, params)

        matches = files.flat_map do |file|
          Helper::LocalizeHelper.stringsFromFile(file)
        end


        matchHash = {}

        matches.each do |match|
          matchHash[match[0]] = [] unless matchHash[match[0]] != nil
          matchHash[match[0]] << match
        end


        whitelist = Helper::LocalizeHelper.getWhitelist

        matchHash.keys
        .map { |match|
          match.gsub(/^\\"/, "\"").gsub(/\\"$/, "\"")
        }
        .reject { |match|
          whitelist.include? match
        }
        .each { |match|

          files.flat_map do |file|
            Helper::LocalizeHelper.showStringOccurrencesFromFile(file, match)
          end

          if UI.confirm "Extract #{match}?"
            key = UI.input "Enter key for localization:"
            Helper::LocalizeHelper.localize_string(match, key, files, params)
          else
            Helper::LocalizeHelper.addToWhitelist(match)
          end
        }
      end

      def self.description
        "Searches the code for extractable strings and allows interactive extraction to .strings file."
      end

      def self.authors
        ["Wolfgang Lutz"]
      end

      def self.return_value
      end

      def self.details
        "Searches the code for extractable strings and allows interactive extraction to .strings file:"
        "- Whitelists non-extracted strings"
        "- Support for NSLocalizedString and Swiftgen"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :localize_project,
                                     env_name: "FL_LOCALIZE_PROJECT", # The name of the environment variable
                                     description: "The project to localize", # a short description of this parameter
                                     is_string: true, # true: verifies the input is a string, false: every kind of value
                                     default_value: Helper::LocalizeHelper.getProject(nil).path # the default value if the user didn't provide one
                                   ),
          FastlaneCore::ConfigItem.new(key: :use_swiftgen,
                                       env_name: "FL_LOCALIZE_USE_SWIFTGEN", # The name of the environment variable
                                       description: "Localize using Swiftgens L10n ", # a short description of this parameter
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       default_value: false # the default value if the user didn't provide one
                                      ),
          FastlaneCore::ConfigItem.new(key: :strings_file,
                                       env_name: "FL_LOCALIZE_STRINGS_FILE",
                                       description: "The stringsfile to write to",
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       default_value: "Localizable.strings" # the default value if the user didn't provide one,
                                     ),
           FastlaneCore::ConfigItem.new(key: :file_filter,
                                         env_name: "FL_LOCALIZE_FILE_FILTER",
                                         description: "Filter strings for file paths to ignore, separated by commas",
                                         optional: true,
                                         is_string: false
                                       )
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
        true
      end
    end
  end
end
