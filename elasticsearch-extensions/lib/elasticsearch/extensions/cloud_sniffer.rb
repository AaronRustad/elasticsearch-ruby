# encoding: utf-8
require 'fog/aws'

module Elasticsearch
  module Extensions
    module CloudSniffer
      class EC2 < Elasticsearch::Transport::Transport::Sniffer
        attr_reader :filters

        def initialize(transport)
          super

          __setup_cloud
          __setup_filters
          __discover_hosts
        end

        def __discover_hosts
          # TODO: This seems wrong, but the transport needs the first host to make a request
          transport.hosts << 'http://www.test.com:9200'
          # need to clone as the tags are removed
          @cloud.servers.all(filters.clone)
        end

        def __setup_cloud
          @cloud = Fog::Compute.new :provider => 'AWS'
        end

        def __setup_filters
          transport_filters = transport.options[:ec2]

          @filters = {}
          transport_filters.fetch(:tags, {}).each_pair do |key, value|
            @filters["tag:#{key}"] = value
          end

          @filters['availability-zone'] = transport_filters[:availability_zones] if transport_filters[:availability_zones]
          @filters['instance.group-name'] = transport_filters[:groups] if transport_filters[:groups]
        end
      end
    end
  end
end
