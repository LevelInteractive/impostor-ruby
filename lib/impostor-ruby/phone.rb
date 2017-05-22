module Impostor
  ##
  # Phone: Is responsible for allocating a phone number via Twilio or using Faker to generate a fake number.
  class Phone
    ##
    # initialize: Set config as an instances variable.
    def initialize(config)
      @config = config
    end

    ##
    # number: Accepts 3 parameters name, twilio, and area code.  twilio determines if
    # Twilio will be used to generate a real phone number.  Name is used when setting the
    # friendly name of a Twilio phone number. Area code is used when search for local Twilio numbers.
    # End result a phone number.
    def number(twilio=false, name=nil, area_code=nil)
      if twilio
        # Check if twilio configuration exists.  If not throw and errors because twilio was passed as true.
        if !@config[:configuration][:twilio].blank? and (!@config[:configuration][:twilio][:account_id].blank? and !@config[:configuration][:twilio][:api_key].blank?)
          account = @config[:configuration][:twilio][:account_id]
          key = @config[:configuration][:twilio][:api_key]

          # Initialize twilio client.
          twilio = Twilio::REST::Client.new account, key

          # If any area code is provide look for local numbers, if not get a toll free.
          if area_code.blank?
            available_numbers = twilio.account.available_phone_numbers.get('US').toll_free.list
          else
            available_numbers = twilio.account.available_phone_numbers.get('US').local.list(area_code: area_code) unless area_code.blank?
          end

          # Select the first number available.
          available_number = available_numbers.first

          # If available numbers is blank throw an error because something went wrong.
          if available_numbers.blank?
            raise StandardError, "No Available Numbers"
          else

            # Convert the phone number into something a artificial voice can say.
            phone_number = available_number.phone_number.gsub("+1","")
            phone_number = "#{phone_number[0..2]}-#{phone_number[3..5]}-#{phone_number[6..10]}"


            # Setting the transciption email
            # email = @config[:configuration][:twilio][:transcription_email].blank? ? "developers%40level.agency" : @config[:configuration][:twilio][:transcription_email]
            email = "developers%40level.agency"
            # Put together the voicemail Twimil.
            voice_message = "http://twimlets.com/voicemail?Email=#{email}&Message=You%20reached%20the%20voicemail%20box%20of%20#{phone_number}.%20%20Please%20leave%20a%20message%20after%20the%20beep.&Transcribe=true&"

            # Here we buy the number, set the voice_url to the voicemail Twimil and set the
            # sms_url to echo so Twilio will capture the message but not reply to it.
            number = twilio.account.incoming_phone_numbers.create({
              phone_number: available_number.phone_number,
              friendly_name: name,
              voice_url: voice_message,
              voice_method: "GET",
              sms_url: "http://twimlets.com/echo?Twiml=%3CResponse%3E%3C%2FResponse%3E",
              sms_method: "GET"
            })

            # If number is blank throw and error because something went wrong.
            if number.blank?
              raise StandardError, "Unable to allocate Twilio number"
            else
              number.phone_number
            end
          end
        else
          raise ArgumentError, "Cannot find Twilio Account ID and API key in configuration"
        end
      else
        Faker::PhoneNumber.phone_number
      end
    end
  end
end