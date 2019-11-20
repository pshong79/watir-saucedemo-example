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

  it "empty cart" do
    # DESCRIPTION : This test verifies the cart page when it is empty.

    @browser.goto "https://www.saucedemo.com/cart.html"

    # verify empty cart page.
    expect(@browser.div(class: "subheader").text).to eq("Your Cart")
    expect(@browser.span(class: "fa-layers-counter shopping_cart_badge").present?).to be false
    expect(@browser.div(class: "cart_quantity_label").present?).to be true
    expect(@browser.div(class: "cart_desc_label").present?).to be true
    expect(@browser.div(class: "cart_item").present?).to be false
    expect(@browser.a(text: "Continue Shopping").present?).to be true
    expect(@browser.a(text: "CHECKOUT").present?).to be true
  end

  context "add item : " do
    it "one item in cart" do
      # DESCRIPTION : This test verifies when there is one item added to the cart.

      @browser.goto "https://www.saucedemo.com/inventory-item.html?id=0"
      item_name = @browser.div(class: "inventory_details_name").text
      item_price = @browser.div(class: "inventory_details_price").text
      item_price.slice!(0)
#      puts item_price
      @browser.button(text: "ADD TO CART").click
      @browser.a(class: "shopping_cart_link fa-layers fa-fw").click

      # verify on cart page.
      expect(@browser.div(class: "inventory_item_name").text).to eq(item_name)
      expect(@browser.div(class: "cart_quantity").text).to eq("1")
      expect(@browser.div(class: "inventory_item_price").text).to eq(item_price)
    end

    it "multiple items in cart" do
      # DESCRIPTION : This test verifies when there are multiple items added to the cart.

      # add first item.
      @browser.goto "https://www.saucedemo.com/inventory-item.html?id=2"
      item1_name = @browser.div(class: "inventory_details_name").text
      item1_price = @browser.div(class: "inventory_details_price").text
      item1_price.slice!(0)
#      puts item1_price
      @browser.button(text: "ADD TO CART").click

      # add second item.
      @browser.goto "https://www.saucedemo.com/inventory-item.html?id=4"
      item2_name = @browser.div(class: "inventory_details_name").text
      item2_price = @browser.div(class: "inventory_details_price").text
      item2_price.slice!(0)
#      puts item2_price
      @browser.button(text: "ADD TO CART").click
      @browser.a(class: "shopping_cart_link fa-layers fa-fw").click

      # verify on cart page.
      expect(@browser.div(class: "inventory_item_name", :index => 0).text).to eq(item1_name)
      expect(@browser.div(class: "cart_quantity").text).to eq("1")
      expect(@browser.div(class: "inventory_item_price", :index => 0).text).to eq(item1_price)

      expect(@browser.div(class: "inventory_item_name", :index => 1).text).to eq(item2_name)
      expect(@browser.div(class: "cart_quantity").text).to eq("1")
      expect(@browser.div(class: "inventory_item_price", :index => 1).text).to eq(item2_price)
    end
  end

  context "remove item : " do
    it "only 1 item in cart" do
      # DESCRIPTION : This test verifies when the one item in the cart gets removed.

      # add item.
      @browser.goto "https://www.saucedemo.com/inventory-item.html?id=0"
      item_name = @browser.div(class: "inventory_details_name").text
      item_price = @browser.div(class: "inventory_details_price").text
      item_price.slice!(0)
#      puts item_price
      @browser.button(text: "ADD TO CART").click
      @browser.a(class: "shopping_cart_link fa-layers fa-fw").click

      # verify on cart page.
      expect(@browser.div(class: "inventory_item_name").text).to eq(item_name)
      expect(@browser.div(class: "cart_quantity").text).to eq("1")
      expect(@browser.div(class: "inventory_item_price").text).to eq(item_price)

      # remove item.
      @browser.button(text: "REMOVE").click
      expect(@browser.span(class: "fa-layers-counter shopping_cart_badge").present?).to be false
      expect(@browser.div(class: "cart_item").present?).to be false
    end

    it "more than 1 same item" do
      # DESCRIPTION : This test verifies removing reducing the quantity of an item by 1.

      # NOTE : This scenario is not valid since
      #        1. quantity field is non-editable;
      #        2. site does not allow for multiple quantities of the same item in the cart.
    end

    it "multiple different items" do
      # DESCRIPTION : This test verifies removing one item when there are multiple items in the cart.

      # add first item.
      @browser.goto "https://www.saucedemo.com/inventory-item.html?id=2"
      item1_name = @browser.div(class: "inventory_details_name").text
      item1_price = @browser.div(class: "inventory_details_price").text
      item1_price.slice!(0)
#      puts item1_price
      @browser.button(text: "ADD TO CART").click

      # add second item.
      @browser.goto "https://www.saucedemo.com/inventory-item.html?id=4"
      item2_name = @browser.div(class: "inventory_details_name").text
      item2_price = @browser.div(class: "inventory_details_price").text
      item2_price.slice!(0)
#      puts item2_price
      @browser.button(text: "ADD TO CART").click
      item_count = @browser.span(class: "fa-layers-counter shopping_cart_badge").text
      expect(item_count).to eq("2")
      @browser.a(class: "shopping_cart_link fa-layers fa-fw").click

      # remove one item.
      @browser.button(text: "REMOVE", :index => 1).click
      item_count = @browser.span(class: "fa-layers-counter shopping_cart_badge").text

      # first item remains.
      expect(item_count).to eq("1")
      expect(@browser.div(class: "inventory_item_name", :index => 0).text).to eq(item1_name)
      expect(@browser.div(class: "cart_quantity").text).to eq("1")
      expect(@browser.div(class: "inventory_item_price", :index => 0).text).to eq(item1_price)

      # removed item no longer appears.
      expect(@browser.div(class: "inventory_item_name", :index => 1).present?).to be false

      # remove second item.
      @browser.button(text: "REMOVE").click

      # cart is empty.
      expect(@browser.span(class: "fa-layers-counter shopping_cart_badge").present?).to be false
      expect(@browser.div(class: "cart_item").present?).to be false

    end
  end

  it "continue shopping" do
    # DESCRIPTION : This test verifies when user decides to continue shopping.

    @browser.goto "https://www.saucedemo.com/cart.html"
    @browser.a(text: "Continue Shopping").click

    # verify going back to inventory page.
    page_url = @browser.url
    expect(page_url).to eq("https://www.saucedemo.com/inventory.html")
    expect(@browser.a(id: "item_4_img_link")).to have_attributes(href: "https://www.saucedemo.com/inventory-item.html?id=4")
  end

  it "go back to item details" do
    # DESCRIPTION : This test verifies going back to the item's detail page.

    @browser.goto "https://www.saucedemo.com/inventory-item.html?id=0"
    item_name = @browser.div(class: "inventory_details_name").text
    item_price = @browser.div(class: "inventory_details_price").text
    item_price.slice!(0)
#      puts item_price
    @browser.button(text: "ADD TO CART").click

    # go to cart.
    @browser.a(class: "shopping_cart_link fa-layers fa-fw").click
    expect(@browser.div(class: "inventory_item_name").text).to eq(item_name)

    # click item name.
    @browser.div(class: "inventory_item_name").click

    # verify item's detail page loaded.
    expect(@browser.div(class: "inventory_details_name").text).to eq(item_name)
  end

  it "go to checkout" do
    # DESCRIPTION : This test verifies going to checkout.

    @browser.goto "https://www.saucedemo.com/cart.html"
    @browser.a(text: "CHECKOUT").click

    #verify going back to inventory page.
    page_url = @browser.url
    expect(page_url).to eq("https://www.saucedemo.com/checkout-step-one.html")
    expect(@browser.div(class: "subheader").text).to eq("Checkout: Your Information")
  end
end
