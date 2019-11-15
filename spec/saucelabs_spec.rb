require 'watir'
require 'faker'


standard_user = "standard_user"
locked_out_user = "locked_out_user"
problem_user = "problem_user"
performance_glitch_user = "performance_glitch_user"
password = "secret_sauce"

lock_out_error = "Epic sadface: Sorry, this user has been locked out."

describe "login : " do
  before(:each) do
    @browser = Watir::Browser.new
    @browser.goto "https://www.saucedemo.com/"
  end

  after(:each) do
    @browser.quit
  end

  it "standard_user - successful" do
    @browser.text_field(id: "user-name").set standard_user
    @browser.text_field(id: "password").set password
    @browser.button(value: "LOGIN").click

#    @browser.url == "https://www.saucedemo.com/inventory.html" # FIXME
    expect(@browser.a(id: "item_4_img_link")).to have_attributes(href: "https://www.saucedemo.com/inventory-item.html?id=4")
  end

  it "locked_out_user - error message" do
    @browser.text_field(id: "user-name").set locked_out_user
    @browser.text_field(id: "password").set password
    @browser.button(value: "LOGIN").click

    expect(@browser.h3.text).to eq(lock_out_error)
  end

  it "problem_user - successful" do
    @browser.text_field(id: "user-name").set problem_user
    @browser.text_field(id: "password").set password
    @browser.button(value: "LOGIN").click

    expect(@browser.a(id: "item_4_img_link")).to have_attributes(href: "https://www.saucedemo.com/inventory-item.html?id=4")
  end

  it "performance_glitch_user - successful" do
  end
end
