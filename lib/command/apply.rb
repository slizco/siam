require 'securerandom'
require 'file'

require 'siam/awsclient'

module Siam
  class Command
    module Apply

      SIAM_FILE = '.siam'.freeze
      ROLE_PREFIX = 'siam-test'.freeze

      class << self

        def cached?
          return File.exist?(SIAM_FILE)
        end

        def uuid(opts)
          if opts[:cached]
            puts "Role cached, fetching identifier"
            id = File.read(SIAM_FILE)
            if id.nil? || id.empty?
              puts "Empty identifier, please run 'siam clear' before applying"
              exit 1
            end
          else
            puts "No role cached, creating new identifier"
            id = SecureRandom.uuid
            File.write(SIAM_FILE, id)
          end
          id
        end

        def run(role_file)
          if !File.exists(role_file)
            puts "No role file found at #{role_file}."
            exit 1
          end

          role = File.read(role_file)

          if cached?
            AWSClient::IAM.upsert((role, ROLE_PREFIX, uuid(cached: true))
          else
            AWSClient::IAM.create(role, ROLE_PREFIX, uuid(cached: false))
          end
        end

      end
    end
  end
end
