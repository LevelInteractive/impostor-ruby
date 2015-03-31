module Impostor
  class Klass

    ##
    # Default configuration for gem.  location_db provides datastate adapter information to pull
    # from a location database and the column mappings.  Configuration holds Twilio configuration 
    # information as well as domains to use while generating email addresses.
    DEFAULTS = {
      location_db: {
        adapter: :mysql,
        mysql:{
          host: '127.0.0.1',
          username: 'root',
          password: nil,
          database: 'zipcodes',
        },
        column_mapping: {
          zip_code: 'zip_code',
          city: 'city_name',
          state: 'state_name',
          state_abbr: 'state_abbr',
          area_code: 'area_code',
        },
        table: 'locations'
      },
      configuration:{
        domains: [],
        twilio: {},
        location_db_table: 'locations'
      }
    }

    ##
    # initialize: Merge options with defaults setup datastore connection and resources.
    def initialize(options={})
      @config = DEFAULTS.merge! options
      setup_database_connection
      setup_resources
    end

    attr_reader :config, :address, :internet, :phone, :personal, :persona

    private

    ##
    # setup_resources: Make all resources available from the  Impostor class.  
    def setup_resources

      # Address requires the passage of the @config and @db for location query's.
      @address = Address.new @config, @db
      @internet = Internet.new @config
      @phone = Phone.new @config
      @personal = Personal.new

      # Pass the Klass itself to Persona to give it access to the other resources and configuration.
      @persona = Persona.new self
    end

    ##
    # setup_database_connection: Setup appropriate adapter.
    def setup_database_connection
      case @config[:location_db][:adapter]
      when :mysql
        @db = Mysql2::Client.new(host: @config[:location_db][:mysql][:host], username: @config[:location_db][:mysql][:username], password: @config[:location_db][:mysql][:password], database: @config[:location_db][:mysql][:database])
      else
        @db = nil
      end
    end
  end
end