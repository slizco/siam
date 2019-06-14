require 'optimist'

module Siam
  class Command
    attr_reader :cmd, :terms

    SUB_COMMANDS = %w(apply destroy clear).freeze

    def initialize(args)
      @terms = args.dup
      @cmd = @terms.first
      parse_global_args(@terms)

      Optimist.die 'no command called' if @cmd.nil? || @cmd.empty?

      execute
    end

    def parse_global_args(terms)
      Optimist.options(terms) do
        banner 'Simulate IAM roles and policies'
        stop_on SUB_COMMANDS
      end
    end

    def parse_apply_args(terms)
      Optimist.options(terms) do
        banner 'Apply changes to create or modify an IAM role'
        opt :role_file, 'Path to file for role', short: 'f', type:String
      end
    end

    def parse_destroy_args(terms)
      Optimist.options(terms) do
        banner 'Destroy an existing IAM role'
      end
    end

    def parse_clear_args(terms)
      Optimist.options(terms) do
        banner "Clear the cached IAM role.\nNote that this will not destroy the role in IAM,\nbut will force creation of a new role upon the next 'apply'."
      end
    end

    def execute
      case @cmd
      when "apply"
        parse_apply_args(@terms)
        puts "applying"
      when "destroy"
        parse_destroy_args(@terms)
        puts "destroying"
      when "clear"
        parse_clear_args(@terms)
        puts "clearing"
      else
        Optimist.die "Unrecognized subcommand '#{@cmd}'"
    end


    end
  end
end

app = Siam::Command.new(ARGV)
