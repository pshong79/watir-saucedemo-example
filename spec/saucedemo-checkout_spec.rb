require 'watir'
require 'faker'

standard_user = "standard_user"
password = "secret_sauce"

FIRST_NAME_REQUIRED_ERROR = "Error: First Name is required"
LAST_NAME_REQUIRED_ERROR = "Error: Last Name is required"
POSTAL_CODE_REQUIRED_ERROR = "Error: Postal Code is required"

describe "checkout : " do
  before(:each) do
    @browser = Watir::Browser.new
    @browser.goto "https://www.saucedemo.com/"
    @browser.text_field(id: "user-name").set standard_user
    @browser.text_field(id: "password").set password
    @browser.button(value: "LOGIN").click

    @browser.goto "https://www.saucedemo.com/inventory-item.html?id=0"
    item_name = @browser.div(class: "inventory_details_name").text
    item_price = @browser.div(class: "inventory_details_price").text
    @browser.button(text: "ADD TO CART").click
    @browser.a(class: "shopping_cart_link fa-layers fa-fw").click
  end

  after(:each) do
    @browser.quit
  end

  it "checkout successful" do
    # DESCRIPTION : This test verifies successfully checking out.

    # grab details for item in cart.
    item_name = @browser.div(class: "inventory_item_name").text
    item_price = @browser.div(class: "inventory_item_price").text
    item_price_2 = "$" + item_price
    item_qty = @browser.div(class: "cart_quantity").text

    @browser.a(text: "CHECKOUT").click

    # complete first page of checkout.
    @browser.text_field(id: "first-name").set Faker::Name.first_name
    @browser.text_field(id: "last-name").set Faker::Name.last_name
    @browser.text_field(id: "postal-code").set Faker::Address.zip_code
    @browser.input(value: "CONTINUE").click

    # verify order accuracy.
    expect(@browser.div(class: "inventory_item_name").text).to eq(item_name)
    expect(@browser.div(class: "inventory_item_price").text).to eq(item_price_2)
    expect(@browser.div(class: "summary_quantity").text).to eq(item_qty)

    subtotal = @browser.div(class: "summary_subtotal_label").text
    subtotal = subtotal.slice!(13..17)
#    puts "subtotal: " + subtotal

    tax = @browser.div(class: "summary_tax_label").text
    tax = tax.slice!(6..9)
#    puts "tax: " + tax

    tax_rate = 0.08
    calc_tax = tax_rate * item_price.to_f

    total = @browser.div(class: "summary_total_label").text
    total = total.slice!(8..12)
#    puts "total: " + total

    expected_total = item_price.to_f + calc_tax

    expect("$" + subtotal).to eq(item_price_2)
    expect(tax.to_f).to eq(calc_tax.round(2))
    expect("$" + total).to eq("$" + expected_total.round(2).to_s)
    @browser.a(text: "FINISH").click

    # verify confirmation page.
    page_url = @browser.url
    expect(page_url).to eq("https://www.saucedemo.com/checkout-complete.html")
    expect(@browser.div(class: "subheader").text).to eq("Finish")
    expect(@browser.h2(class: "complete-header").text).to eq("THANK YOU FOR YOUR ORDER")
  end

  it "cancel on checkout page 1" do
    @browser.goto "https://www.saucedemo.com/checkout-step-one.html"
    @browser.a(text: "CANCEL").click

    #verify going back to cart.
    page_url = @browser.url
    expect(page_url).to eq("https://www.saucedemo.com/cart.html")
    expect(@browser.div(class: "subheader").text).to eq("Your Cart")
  end

  it "cancel on checkout page 2" do
    @browser.goto "https://www.saucedemo.com/checkout-step-two.html"
    @browser.a(text: "CANCEL").click

    #verify going back to inventory page.
    page_url = @browser.url
    expect(page_url).to eq("https://www.saucedemo.com/inventory.html")
    expect(@browser.a(id: "item_4_img_link")).to have_attributes(href: "https://www.saucedemo.com/inventory-item.html?id=4")
  end

  context "error handling : " do
    it "first name required" do
      # DESCRIPTION : This test verifies the error when the first name field is left blank.

      @browser.goto "https://www.saucedemo.com/checkout-step-one.html"
      @browser.text_field(id: "last-name").set Faker::Name.last_name
      @browser.text_field(id: "postal-code").set Faker::Address.zip_code
      @browser.input(value: "CONTINUE").click

      expect(@browser.h3.text).to eq(FIRST_NAME_REQUIRED_ERROR)
    end

    it "last name required" do
      # DESCRIPTION : This test verifies the error when the last name field is left blank.

      @browser.goto "https://www.saucedemo.com/checkout-step-one.html"
      @browser.text_field(id: "first-name").set Faker::Name.first_name
      @browser.text_field(id: "postal-code").set Faker::Address.zip_code
      @browser.input(value: "CONTINUE").click

      expect(@browser.h3.text).to eq(LAST_NAME_REQUIRED_ERROR)
    end

    it "zip/postal code required" do
      # DESCRIPTION : This test verifies the error when the postal code field is left blank.

      @browser.goto "https://www.saucedemo.com/checkout-step-one.html"
      @browser.text_field(id: "first-name").set Faker::Name.first_name
      @browser.text_field(id: "last-name").set Faker::Name.last_name
      @browser.input(value: "CONTINUE").click

      expect(@browser.h3.text).to eq(POSTAL_CODE_REQUIRED_ERROR)
    end
  end
end
