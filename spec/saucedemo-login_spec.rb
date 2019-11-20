require 'watir'

standard_user = "standard_user"
locked_out_user = "locked_out_user"
problem_user = "problem_user"
performance_glitch_user = "performance_glitch_user"
password = "secret_sauce"
invalid_password = "invalid"

LOCK_OUT_ERROR = "Epic sadface: Sorry, this user has been locked out."
INVALID_USERNAME_PASSWORD_ERROR = "Epic sadface: Username and password do not match any user in this service"
USERNAME_REQUIRED_ERROR = "Epic sadface: Username is required"
PASSWORD_REQUIRED_ERROR = "Epic sadface: Password is required"


describe "login : " do
  before(:each) do
    @browser = Watir::Browser.new
    @browser.goto "https://www.saucedemo.com/"
  end

  after(:each) do
    @browser.quit
  end

  it "standard_user - successful" do
    # DESCRIPTION : This test verifies loggin in successfully.

    @browser.text_field(id: "user-name").set standard_user
    @browser.text_field(id: "password").set password
    @browser.button(value: "LOGIN").click

    # NOTE : Probably not the best way to confirm successful log in - will need to eventually update this.
    # check to make sure first image properly loads with correct file.
    expect(@browser.a(id: "item_4_img_link")).to have_attributes(href: "https://www.saucedemo.com/inventory-item.html?id=4")
  end

  it "log out - successful" do
    # DESCRIPTION : This test verifies successfully logging out.

    @browser.text_field(id: "user-name").set standard_user
    @browser.text_field(id: "password").set password
    @browser.button(value: "LOGIN").click

    # log out.
    @browser.button(text: "Open Menu").click
    @browser.a(id: "logout_sidebar_link").click

    # verify successful log out.
    expect(@browser.div(class: "login_credentials_wrap").present?).to be true
  end

  # NOTE : This test SHOULD fail because image file it is expecting is not the one that is actually loaded.
  it "problem_user - successful" do
    # DESCRIPTION : This test verifies a problem with the user.
    #               In this case, the images do not correctly load.
    #               This test SHOULD fail.

    @browser.text_field(id: "user-name").set problem_user
    @browser.text_field(id: "password").set password
    @browser.button(value: "LOGIN").click

    # NOTE : Probably not the best way to confirm successful log in - will need to eventually update this.
    # same check as in the "standard_user" test but in this case, test should fail because incorrect image is loaded causing it to be a broken image preview.
    expect(@browser.a(id: "item_4_img_link")).to have_attributes(href: "https://www.saucedemo.com/inventory-item.html?id=4")
  end

  it "performance_glitch_user - successful" do
    # not really sure how to test for performance glitch yet.
    # need to try to understand what the actual issue is and how to quantify that to create this test.
  end

  context "error handling : " do
    it "locked_out_user" do
      # DESCRIPTION : This test verifies error-handling when a user is locked out.

      @browser.text_field(id: "user-name").set locked_out_user
      @browser.text_field(id: "password").set password
      @browser.button(value: "LOGIN").click

      # verify lock out error message displays.
      expect(@browser.h3.text).to eq(LOCK_OUT_ERROR)
    end

    it "standard_user - not successful" do
      # DESCRIPTION : This test verifies error-handling for when the password is not valid.

      @browser.text_field(id: "user-name").set standard_user
      @browser.text_field(id: "password").set invalid_password
      @browser.button(value: "LOGIN").click

      # verify lock out error message displays.
      expect(@browser.h3.text).to eq(INVALID_USERNAME_PASSWORD_ERROR)
    end

    it "username is required" do
      # DESCRIPTION : This test verifies error-handling for when the username field is blank.

      @browser.text_field(id: "password").set invalid_password
      @browser.button(value: "LOGIN").click

      # verify lock out error message displays.
      expect(@browser.h3.text).to eq(USERNAME_REQUIRED_ERROR)
    end

    it "password is required" do
      # DESCRIPTION : This test verifies error-handling for when the password field is blank.

      @browser.text_field(id: "user-name").set standard_user
      @browser.button(value: "LOGIN").click

      # verify lock out error message displays.
      expect(@browser.h3.text).to eq(PASSWORD_REQUIRED_ERROR)
    end
  end
end
