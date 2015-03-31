module Impostor
  ##
  # Persona: This class is responsible for generating an entire lead record.
  class Persona
    ##
    # initialize: Set passed client as an instances variable.
    def initialize(client)
      @client = client
    end

    ##
    # generate: This is the main method that will be used when generating a new lead record.
    # Options can be passed such as twilio, which will determine if a twilio number should be
    # allocated, and restrictions, which will tell which state or zip codes should be used.
    # The end result is a complete lead record.
    def generate(options={ twilio: false, restrictions: {state: [],zip_code: []} })
      opts = { twilio: false, restrictions: {state: [],zip_code: []} }.merge! options
      persona = {}

      persona[:personal] = {
        first_name: @client.personal.first_name,
        last_name: @client.personal.last_name
      }

      persona[:address] = @client.address.location opts[:restrictions]

      persona[:internet] = {
        email: @client.internet.email("#{persona[:personal][:first_name]} #{persona[:personal][:last_name]}")
      }

      persona[:phone] = {
        number: @client.phone.number(opts[:twilio],"#{persona[:personal][:first_name]} #{persona[:personal][:last_name]}", persona[:address][:area_code])
      }

      persona
    end
  end
end