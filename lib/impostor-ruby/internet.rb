module Impostor
  ##
  # Internet: This class provides methods to create internet related things at random or
  # with specific content.
  class Internet

    ##
    # initialize: Set @domains from configuration.
    def initialize(config)
      @domains = config[:configuration][:domains]
    end

    ##
    # email: Accepts an optional name which will be used in the generation of an email address.
    # If @domains contains multiple domains the domains will be selected at random to create a
    # new email address.  If no domains are set Faker will generate an email address.
    def email(name=nil)
      if @domains.count > 0
        domain = @domains.count > 1 ? @domains[rand(1..@domains.count) - 1] : @domains.first
      else
        domain = nil
      end

      domain.nil? ? Faker::Internet.email(name) : Faker::Internet.email(name).split("@").first + "@" + domain
    end
  end
end