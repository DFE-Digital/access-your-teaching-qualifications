module CheckRecords
  module AuthenticationSteps
    def when_i_sign_in_via_dsi
      given_dsi_auth_is_mocked
      when_i_visit_the_sign_in_page
      and_click_the_dsi_sign_in_button
    end
    alias_method :and_i_am_signed_in_via_dsi, :when_i_sign_in_via_dsi

    def given_dsi_auth_is_mocked
      OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
        {
          provider: "dfe",
          uid: "123456",
          info: {
            email: "test@example.com",
            first_name: "Test",
            last_name: "User"
          },
          extra: {
            raw_info: {
              organisation: {
                "id" => "C43598D7-CB91-4FF3-870E-4504F1CE6FDE",
                "name" => "DSI TEST Other Stakeholders (008)",
                "category" => {
                  "id" => "008",
                  "name" => "Other Stakeholders"
                },
                "urn" => nil,
                "uid" => nil,
                "upin" => nil,
                "ukprn" => "00000044",
                "establishmentNumber" => nil,
                "status" => {
                  "id" => 1,
                  "name" => "Open"
                },
                "pimsStatus" => nil,
                "closedOn" => nil,
                "address" => nil,
                "telephone" => nil,
                "statutoryLowAge" => nil,
                "statutoryHighAge" => nil,
                "legacyId" => "0000",
                "companyRegistrationNumber" => "1234",
                "DistrictAdministrativeCode" => nil,
                "DistrictAdministrative_code" => nil,
                "providerTypeName" => nil,
                "LegalName" => nil
              }
            }
          }
        }
      )

      Organisation.create!(company_registration_number: "1234")
    end

    def when_i_visit_the_sign_in_page
      visit check_records_sign_in_path
    end

    def and_click_the_dsi_sign_in_button
      click_button "Sign in with DSI"
    end
  end
end
