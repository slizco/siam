require 'optimist'
module Siam
  class Command
      attr_reader :terms, :cmd

      SUB_COMMANDS = %w(init apply destroy clear)

      def initialize(args)
        @terms = args.dup

        parse_global

        Optimist.die 'No subcommand specified' if @terms.empty?

        @cmd = @terms.first
      end

      def execute
        parse_sub
      end

      def parse_global
        Optimist.options(@terms) do
          banner 'Simulate IAM roles and policies on the command line.'
          stop_on SUB_COMMANDS
        end
      end

      def parse_sub
        case @cmd
          when 'init'
            Optimist.options(@terms) do
              banner "Initialize a project to use Siam.\nWill create a cached identifier and and store info about Slack channel to target."
              opt :slack_channel, 'Slack channel where IAM role deletion messages will be sent', short: 's', type: String
            end
            puts "initializing"
          when 'apply'
            Optimist.options(@terms) do
              banner 'Apply changes to create or modify an IAM role with passed policy file.'
              opt :policy_file, 'Path to policy file to use', short: 'p', type: String, default: './policy.json'
            end
            puts "applying"
          when 'destroy'
            Optimist.options(@terms) do
              banner 'Destroys an IAM role by deleting it in AWS.'
            end
            puts "destroying"
          when "clear"
            Optimist.options(@terms) do
              banner 'Clears the cached role identifier and Slack channel info.'
            end
            puts "clearing"
          else
            Optimist.die "Unknown subcommand '#{@cmd}'"
          end
      end

  end
end

cmd = Siam::Command.new(ARGV)
cmd.execute
