module Impostor
  ##
  # Personal: This class is responsible for generating fake names.
  class Personal

    ##
    # first_name: Faker will generate a first name.
    def first_name
      Faker::Name.first_name
    end

    ##
    # last_name: Faker will generate a last name.
    def last_name
      Faker::Name.last_name
    end

    ##
    # full_name: Faker will generate a full name.
    def full_name
      Faker::Name.name
    end
  end
end