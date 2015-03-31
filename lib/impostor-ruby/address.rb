module Impostor
  ##
  # Address: This class provides methods to create addresses either purely random or
  # based on actual general locations such as city and state.
  class Address
    
    ##
    # initialize: Set passed config and db as instances variables. 
    def initialize(config, db)
      @config = config
      @db = db
    end

    ##
    # street: Generate a fake street address using Faker.
    def street
      Faker::Address.street_address
    end

    ##
    # city: If an adapter is set in the configuration this method calls the find_location method
    # to return a real city.  State and zip code restrictions can be passed in to limit results.
    # If find_location does not return a city or adapter is not set a city is generated by Faker.
    def city(restrictions={state: [], zip_code: []})
      city = nil
      state = restrictions[:state].is_a?(Array) and !restrictions[:state].blank? ? restrictions[:state] : []
      zip_codes = restrictions[:zip_code].is_a?(Array) and !restrictions[:zip_code].blank? ? restrictions[:zip_code] : []

      unless @config[:location_db][:adapter].eql?(:none)
        city = find_location(state,zip_codes)["#{@config[:location_db][:column_mapping][:city]}"]
      end

      city = Faker::Address.city if city.blank?

      city
    end

    ##
    # state: If an adapter is set in the configuration this method calls the find_location method
    # to return a real state.  State and zip code restrictions can be passed in to limit results.
    # If find_location does not return a state or adapter is not set a state is generated by Faker.
    # abbreviated parameter can be set to determine if the full state name or the abbreviated name is
    # returned.
    def state(restrictions={state: [], zip_code: []}, abbreviated=true)
      state = nil
      state = restrictions[:state].is_a?(Array) and !restrictions[:state].blank? ? restrictions[:state] : []
      zip_codes = restrictions[:zip_code].is_a?(Array) and !restrictions[:zip_code].blank? ? restrictions[:zip_code] : []

      unless @config[:location_db][:adapter].eql?(:none)
        if abbreviated
          state = find_location(state, zip_codes)["#{@config[:location_db][:column_mapping][:state]}"]
        else
          state = find_location(state, zip_codes)["#{@config[:location_db][:column_mapping][:state_abbr]}"]
        end
      end

      if state.blank?
        state = abbrivated ? Faker::Address.state_abbr : Faker::Address.state
      end

      state
    end

    ##
    # zip_code: If an adapter is set in the configuration this method calls the find_location method
    # to return a real zip code.  State and zip code restrictions can be passed in to limit results.
    # If find_location does not return a zip code or adapter is not set a zip code is generated by Faker.
    def zip_code(restrictions={state: [], zip_code: []})
      zip_code = nil
      state = restrictions[:state].is_a?(Array) and !restrictions[:state].blank? ? restrictions[:state] : []
      zip_codes = restrictions[:zip_code].is_a?(Array) and !restrictions[:zip_code].blank? ? restrictions[:zip_code] : []

      unless @config[:location_db][:adapter].eql?(:none)
        zip_code = find_location(state, zip_codes)["#{@config[:location_db][:column_mapping][:zip_code]}"]
      end

      zip_code = Faker::Address.zip_code if zip_code.blank?

      zip_code
    end

    ##
    # location: If an adapter is set in the configuration this method calls the find_location method
    # to return a full location record.  State and zip code restrictions can be passed in to limit results.
    # If find_location does not return a location or adapter is not set a location is generated by Faker.
    def location(restrictions={state: [], zip_code: []})
      location = {}
      states = (restrictions[:state].is_a?(Array) and !restrictions[:state].blank?) ? restrictions[:state] : []
      zip_codes = (restrictions[:zip_code].is_a?(Array) and !restrictions[:zip_code].blank?) ? restrictions[:zip_code] : []

      unless @config[:location_db][:adapter].eql?(:none)
        location_result = find_location states, zip_codes

        location ={
          city: location_result["#{@config[:location_db][:column_mapping][:city]}"],
          state: location_result["#{@config[:location_db][:column_mapping][:state]}"],
          state_abbr: location_result["#{@config[:location_db][:column_mapping][:state_abbr]}"],
          zip_code: location_result["#{@config[:location_db][:column_mapping][:zip_code]}"],
          area_code: location_result["#{@config[:location_db][:column_mapping][:area_code]}"].split("/").first,
        }
      end

      if location.blank?
        location = {
          street: Faker::Address.street_address,
          city: Faker::Address.city,
          state: Faker::Address.state,
          state_abbr: Faker::Address.state_abbr,
          zip_code: Faker::Address.postal_code,
          area_code: nil
        }
      end

      location
    end

    private

    ##
    # find_location: Compiles the appropriate query based on restrictions and column mappings.
    # the query is then executed.
    def find_location(states=[],zip_codes=[])
      case @config[:location_db][:adapter]
      when :mysql
        query = "select * from #{@config[:location_db][:table]}"
        query += " where " unless states.blank? and zip_codes.blank?

        unless states.blank?
          query += "#{@config[:location_db][:column_mapping][:state_abbr]} in (#{states.map{ |s| "'#{s}'" }.join(',')})"
          query += " and " unless zip_codes.blank?
        end

        unless zip_codes.blank?
          query += "#{@config[:location_db][:column_mapping][:zip_code]} in (#{zip_codes.map{ |s| "'#{s}'" }.join(',')})"
        end

        query += " order by rand() limit 1"

        @db.query(query).first
      else
        nil
      end
    end
  end 
end