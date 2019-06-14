require 'aws-sdk-iam'

module Siam
  module AWSClient
    class IAM

      attr_accessor :client

      def initialize
        region = ENV['AWS_REGION'] || 'us-east-1'
        @client = Aws::IAM::Client.new(region_name: region)
      end

      def role_name
        "#{prefix}-#{uuid}"
      end

      def role_exists?(prefix, uuid)
        resp = @client.get_role({
          role_name: role_name(prefix, uuid)
        })
        resp.nil?
      end

      def policy_name(uuid)
        "policy-#{uuid}"
      end

      def assume_role_policy
        ''
      end

      def update_role(policy, prefix, uuid)
        rn = role_name(prefix, uuid)
        resp = @client.put_role_policy({
          policy_document: policy,
          policy_name: policy_name(uuid),
          role_name: rn
        })
        if resp.nil?
          puts "Failed to update role #{rn}"
          exit 1
        end
        resp.role_name
      end

      def create_role(policy, prefix, uuid)
        rn = role_name(prefix, uuid)
        resp = @client.create_role({
            assume_role_policy_document: assume_role_policy,
            role_name: rn
        })
        if resp.nil?
          puts "Failed to create role #{rn}"
          exit 1
        end
        role_arn = resp.role_arn

        resp = @client.put_role_policy({
          policy_document: policy,
          policy_name: policy_name(uuid),
          role_name: rn
        })
        if resp.nil?
          puts "Failed to attach policy to role #{rn}"
          exit 1
        end
        role_arn
      end

      def delete_role(prefix, uuid)
        resp = @client.delete_role({
          role_name: rn
        })
        if resp.nil?
          puts "Failed to delete #{rn}"
          exit 1
        end
        resp.role_name
      end

      def upsert(policy, prefix, uuid)
        if role_exists?(prefix, uuid)
          update_role(policy, prefix, uuid)
        else
          create_role(policy, prefix, uuid)
        end
      end

    end
  end
end
