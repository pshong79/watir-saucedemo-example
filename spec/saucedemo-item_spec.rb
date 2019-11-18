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
    # DESCRIPTION : This test verifies pages loading the item's detail page when clicking the item's image.

    # multiple objects have the same class
    # ":index => 2" is used to click on the third item
    item_name = @browser.div(class: "inventory_item_name", :index => 2).text
#    puts "item : " + item_name
    @browser.img(class: "inventory_item_img", :index => 2).click

    # confirm correct item loaded
    expect(@browser.div(class: "inventory_details_name").text).to eq(item_name)
  end

  it "view - click name" do
    # DESCRIPTION : This test verifies pages loading the item's detail page when clicking the item's name.
    item_name = @browser.div(class: "inventory_item_name", :index => 5).text
#    puts "item : " + item_name
    @browser.div(class: "inventory_item_name", :index => 5).click

    # confirm correct item loaded
    expect(@browser.div(class: "inventory_details_name").text).to eq(item_name)
  end

  it "click back" do
    # DESCRIPTION : This test verifies pages loading correctly when using the "Back" button on the item details page.
    page_url = @browser.url
#    puts "page_url : " + page_url

    item_name = @browser.div(class: "inventory_item_name", :index => 4).text
#    puts "item : " + item_name
    @browser.div(class: "inventory_item_name", :index => 4).click

    # confirm correct item loaded
    expect(@browser.div(class: "inventory_details_name").text).to eq(item_name)

    @browser.button(class: "inventory_details_back_button").click
    back_url = @browser.url
#    puts "back_url : " + back_url
    expect(back_url).to eq(page_url)
    expect(@browser.a(id: "item_4_img_link")).to have_attributes(href: "https://www.saucedemo.com/inventory-item.html?id=4")

  end

  it "browser back" do
    # DESCRIPTION : This test verifies pages loading correctly when using the "Back" button on the browser.
    page_url = @browser.url
#    puts "page_url : " + page_url

    item_name = @browser.div(class: "inventory_item_name", :index => 4).text
#    puts "item : " + item_name
    @browser.div(class: "inventory_item_name", :index => 4).click

    # confirm correct item loaded
    expect(@browser.div(class: "inventory_details_name").text).to eq(item_name)

    @browser.back
    back_url = @browser.url
#    puts "back_url : " + back_url
    expect(back_url).to eq(page_url)
    expect(@browser.a(id: "item_4_img_link")).to have_attributes(href: "https://www.saucedemo.com/inventory-item.html?id=4")
  end

  it "add to cart" do
    # DESCRIPTION : This test only verifies adding an item to the cart.
    # It DOES NOT verify the item on the actual cart page.
    item_name = @browser.div(class: "inventory_item_name", :index => 3).text
#    puts "item : " + item_name
    @browser.div(class: "inventory_item_name", :index => 3).click

    # confirm correct item loaded
    expect(@browser.div(class: "inventory_details_name").text).to eq(item_name)

    # get price of item
    price = @browser.div(class: "inventory_details_price").text_field
    items_in_cart_flag = @browser.span(class: "fa-layers-counter shopping_cart_badge").present?
    puts items_in_cart_flag

    if items_in_cart_flag
      items_count = @browser.span(class: "fa-layers-counter shopping_cart_badge").text.to_i
    else
      # do nothing and continue
    end

    # add item to cart
    @browser.button(class: "btn_primary btn_inventory").click

    if items_in_cart_flag
      expect(@browser.span(class: "fa-layers-counter shopping_cart_badge").text).to eq(items_count + 1)
    else
      expect(@browser.span(class: "fa-layers-counter shopping_cart_badge").text.to_i).to eq(1)
    end

    expect(@browser.button(class: "btn_secondary btn_inventory").text).to eq("REMOVE")
  end
end
