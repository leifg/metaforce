require 'savon'

module Metaforce
  module Metadata
    class Client
      def initialize(options={})
        @session = Services::Client.new(options).session
        @client = Savon::Client.new File.expand_path("../../../../wsdl/23.0/metadata.xml", __FILE__) do |wsdl|
          wsdl.endpoint = @session[:metadata_server_url]
        end
        @header = {
            "ins0:SessionHeader" => {
              "ins0:sessionId" => @session[:session_id]
            }
        }
      end

      # Specify an array of component types to list
      #
      # example:
      # [
      #   { :type => "ApexClass" },
      #   { :type => "ApexComponent" }
      # ]
      def list(queries=[])
        unless queries.class == Array
          queries = [ queries ]
        end
        response = @client.request(:list_metadata) do |soap|
          soap.header = @header
          soap.body = {
            :queries => queries
          }
        end
        response.body[:list_metadata_response][:result]
      end

      # Describe the organization's metadata
      def describe
        response = @client.request(:describe_metadata) do |soap|
          soap.header = @header
        end
        response.body[:describe_metadata_response][:result]
      end
    end
  end
end
