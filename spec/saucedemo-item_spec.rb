require 'watir'

standard_user = "standard_user"
password = "secret_sauce"

describe "item : " do
  before(:each) do
    @browser = Watir::Browser.new
    @browser.goto "https://www.saucedemo.com/"
    @browser.text_field(id: "user-name").set standard_user
    @browser.text_field(id: "password").set password
    @browser.button(value: "LOGIN").click
  end

  after(:each) do
    @browser.quit
  end

  it "view - click image" do
    item_name = @browser.div(class: "inventory_item_name").text
    puts "item : " + item_name
    @browser.img(class: "inventory_item_img").click

    # confirm correct item loaded
    expect(@browser.div(class: "inventory_details_name").text).to eq(item_name)
  end

  it "view - click name" do
    item_name = @browser.div(class: "inventory_item_name").text
#    puts "item : " + item_name
    @browser.a(id: "item_1_title_link").click

    # confirm correct item loaded
    expect(@browser.div(class: "inventory_details_name").text).to eq(item_name)
  end

  it "click back" do

  end

  it "add to cart" do

  end
end
