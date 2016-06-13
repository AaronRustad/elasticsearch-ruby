require 'test_helper'
require 'elasticsearch/extensions/cloud_sniffer'

class Elasticsearch::Extensions::CloudSnifferTest < Test::Unit::TestCase
  class DummyTransport
    include Elasticsearch::Transport::Transport::Base
    def __build_connections; hosts; end
  end

  context "EC2" do
    filter_options = {
      ec2: {
        groups: ['group_a', 'group_b'],
        tags:   {'tag_name1' => 'tag_value1', 'tag_name2' => 'tag_value2'},
        availability_zones: ['eu-west-1a', 'eu-west-1b']
      }
    }
    setup do
      Fog.mock!
      @transport = DummyTransport.new(options: filter_options)
      @sniffer   = Elasticsearch::Extensions::CloudSniffer::EC2.new @transport
    end

    teardown do
    end

    should "be initialized with a transport instance" do
      assert_equal @transport, @sniffer.transport
    end

    should "discover available hosts" do
      assert_equal ['http://www.test.com:9200'], @transport.hosts
    end

    should "have group filters" do
      assert_equal(["group_a", "group_b"], @sniffer.filters['instance.group-name'])
    end

    should "have tag filters" do
      filter_options[:ec2][:tags].each_pair do |key, value|
        assert_equal(value, @sniffer.filters["tag:#{key}"])
      end
    end

    should "have availability_zones filters" do
      assert_equal(["eu-west-1a", "eu-west-1b"], @sniffer.filters['availability-zone'])
    end
  end
end

