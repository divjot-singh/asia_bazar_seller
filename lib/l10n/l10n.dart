class L10n {
  // static final String lang = 'en';

  static String fallbackLang = 'en';
  String lang = fallbackLang;

  static final L10n _inst = L10n._internal();

  L10n._internal();

  factory L10n() {
    return _inst;
  }

  String getLocale() {
    return lang;
  }

  // usage:
  // L10n().getStr('foobar');
  // L10n().getStr('foo', {bar: 'baz'});
  String getStr(String id, [Map<String, String> args, String forceLang]) {
    String useLang = forceLang ?? lang;
    String text = strings[useLang][id];
    if (text != null && args != null) {
      args.forEach((final String key, final value) {
        if (text.contains(key)) text = text.replaceFirst('{$key}', value ?? '');
      });
    }
    if (text == null) {
      if (useLang == fallbackLang) {
        text = id;
      } else {
        // fallback to english
        text = getStr(id, args, fallbackLang);
      }
    }
    return text;
  }
}

Map<String, Map<String, String>> strings = {
  "en": {
    "error.ERROR_INVALID_VERIFICATION_CODE": "Invalid otp",
    "error.invalidPhoneNumber": "Invalid phone number",
    "error.invalidCredential": "Invalid phone number",
    "error.verifyPhoneNumberError": "Some error in authentication",
    "error.verificationFailed": "Verification Failed",
    "error.ADMIN_ALREADY_ADDED":"This number is already registered as an admin on Asia Bazar",
    "error.ITEM_OUT_OF_STOCK": "Selected quantity is not available in stock",
    "authentication.enterNumber":
        "Please enter your phone number. We will send you a one time password",
    "input.placeholder": "Enter your message here",
    "addUser.name":"Please enter the admin's name",
    "addUser.name.hint":"eg Ram lal",
    "addUser.phoneNumber":"Please enter the admin's phone number",
    "addUser.mode":"Please select admin type",
    "addUser.note":"Note:",
    "addUser.note.admin":"The admin will be able to receive orders, update their status and view inventory",
    "addUser.note.super_admin":"The super admin will have admin privileges plus add and manage other admins/super admins and manage inventory",
    "addUser.add":"Add",
    "addUser.success":"Admin successfully added",
    "manageUser.heading":"Manage admins",
    "manageUser.makeAdmin":"Demote to admin",
    "manageUser.makeSuperAdmin":"Promote to super admin",
    "manageUser.delete":"Delete",
    "phoneAuthentication.resend": "Resend",
    "phoneAuthentication.verify": "Verify",
    "phoneAuthentication.verificationFailed": "Verification Failed",
    "phoneAuthentication.error.provideValue": "Please provide a value!",
    "phoneAuthentication.invalidPhoneNumber": "Please enter a valid number.",
    "phoneAuthentication.error.enterValidOTP": "Please enter a valid OTP.",
    "phoneAuthentication.error.didntGetCode": "I didn't get the code",
    "app.loading": "Loading, please wait...",
    "phoneAuthentication.enterCode":
        "Please enter verification code sent to {number}",
    "redirector.userNotAdmin": "You are not a recognised admin on Asia Bazar",
    "redirector.userNotAdmin.info":
        "Please contact your an Asia Bazar superadmin to provide you the access.",
    "redirector.goBack": "Go Back",
    "home.placed": "Placed",
    "orderDetails.slideTo": "Slide to ",
    "home.all": "All",
    "home.delivered": "Delivered",
    "home.rejected": "Rejected",
    "home.dispatched": "Dispatched",
    "home.approved": "Approved",
    "orderDetails.approve": "Approve",
    "orderDetails.reject": "Reject",
    "orderDetails.reject.confirm": "Are you sure you want to reject the order?",
    "orderDetails.takeCash": "Dont forget to take \$ {amount} in cash",
    "orderDetails.dispatched": "Dispatch order",
    "orderDetails.delivered": "Swipe when delivered",
    "orderDetails.orderDelivered": "Order delivered",
    "orderDetails.orderRejected": "Order rejected",
    "profile.updateProfile": "Update Profile",
    "profile.updateProfile.welcome": "Welcome aboard {username}!",
    "profile.updateprofile.info":
        "Please add a username and address to continue",
    "profile.updateProfile.username": "What should we call you?",
    "profile.updateProfile.address":
        "Please add a default address. You can always change that later.",
    "profile.address.add": "Add location",
    "profile.address.added": "Address succesfully saved",
    "profile.address.error": "Something went wrong",
    "profile.address.addAddress": "Add address",
    "addUser.admin": "Admin",
    "addUser.superAdmin": "Super Admin",
    "home.title": "Home",
    "drawer.hi": "Hi, {name}",
    "drawer.editUsername": "You need to add a username",
    "drawer.inventory": 'Inventory',
    "drawer.logout": "Log out",
    "drawer.orders": "My orders",
    "drawer.addUser": "Add admin",
    "drawer.addressList": "Address book",
    "profile.address.type": "Address type",
    "profile.address.type.home": "Home",
    "profile.address.type.work": "Work",
    "profile.address.type.other": "Other",
    "profile.address": "Address",
    "address.cantLaunch": "Could not launch address",
    "onboarding.title": "Welcome",
    "onboarding.name": "What should we call you?",
    "onboarding.message": "Choose default location",
    "onboarding.next": "Next",
    "orderDetails.choose": "Choose one",
    "onboarding.name.error": "Please enter a value",
    "onboarding.name.hint": "Please choose a username",
    "onboarding.cta.title": "Next",
    "address.default": "Default",
    "home.searchOrder": "Search orders",
    "orderDetails.orderId": "Order id",
    "orderDetails.orderStatus": "Order status",
    "search.enterPhoneNumber": "Phone number of the customer ",
    "search.phoneWithCountryCode":
        "Phone number of the customer with the country code",
    "home.orderCount": "{count} {type} orders",
    "home.drawer.noOrder": "No orders in {type} state",
    "address.updateLocation": "Update location",
    "address.setDefault": "Set as default address",
    "address.edit": "Edit address",
    "address.delete": "Delete address",
    "address.delete.confirmation":
        "Are you sure you want to delete this address?",
    "confirmation.cancel": "Cancel",
    "confirmation.yes": "Yes",
    "confirmation.delete": "Delete",
    "editProfile.username": "Name",
    "editProfile.phone": "Phone number",
    "editProfile.profile": "Profile",
    "editProfile.defaultAddress": "Default address",
    "editProfile.more": "more",
    "myOrders.heading": "My orders",
    "myOrders.noOrders": "You have not placed an order yet!",
    "drawer.cart": "Cart",
    "orderDetails.return.value": "Items value",
    "orderDetails.return": "Return",
    "orderDetails.exchange": "Exchange",
    "orderDetails.chooseItems": "Choose items to return/exchange",
    "cart.empty": "There are no items in your cart. Go back and add some!",
    "list.empty": "No items found",
    "home.search": "Enter phone number",
    "home.searchWithCountryCode": "Enter phone number with country code",
    "home.shopByCategory": "Choose a category",
    "category.search": "Search {category}",
    "searchOrders.search": "Search",
    "item.add": "Add",
    "cart.total": "Grand total",
    "checkout.checkout": "Checkout",
    "checkout.deliverTo": "Deliver to",
    "checkout.change": "Change",
    "checkout.paymentOption": "Choose payment mode",
    "checkout.placeOrder": "Place order",
    "categoryListing.categoryType.outOfStock": "Out of stock items",
    "categoryListing.categoryType.others": "Other items",
    "categoryListing.quantityAvailable": "Quantity available",
    "checkout.paymentMethod.cod": "Cash on delivery",
    "checkout.paymentMethod.razorpay": "Razorpay",
    "checkout.placingOrder": "Placing order",
    "item.outOfStock": "Out of stock",
    "app.search": "Enter atleast 3 characters to start searching..",
    "listing.goToCart": "Go to cart",
    "orderDetails.cashBanner":
        "Please pay the delivery person \$ {amount} in cash.",
    "app.confirm": "Confirm",
    "cart.empty.confirmation": "Are you sure, you want to empty the cart?",
    "cart.refundProcessing": "Refund is being processed.",
    "checkout.itemOutOfStock":
        "Some of the items in your cart are out of stock. Please go back and place the order again. Meanwhile, the refund is being processed",
    "item.selectQuantity": "Select quantity",
    "order.orderId": "Order:",
    'order.placed': 'Order placed',
    'order.placed.info': 'The order was successfully placed',
    'order.approved': 'Order approved',
    "order.approved.waiting": "Waiting for order approval by the seller",
    'order.approved.info': 'The order has been approved by the seller',
    'order.rejected': 'Order rejected',
    'order.rejected.info': 'The order was unfortunately rejected by the seller',
    'order.dispatched': 'Order dispatched',
    "order.dispatched.waiting":
        "The order will be out for delivery in some time.",
    'order.dispatched.info': 'The order is out for delivery',
    'order.delivered': 'Order delivered',
    "order.delivered.waiting":
        "The seller will deliver the order in some time.",
    'order.delivered.info': 'The order was successfully delivered',
    'order.cancelled': 'Order cancelled',
    'order.cancelled.info': 'The order was unfortunately cancelled by you',
    'order.returnRequested': 'Return requested',
    'order.returnRequested.info':
        'You have requested for a return on this order',
    'order.returnApproved': 'Order returned',
    'order.returnApproved.info':
        'The return request was successfully completed',
    'order.returnRejected': 'Order return rejected',
    'order.returnRejected.info':
        'The return request was unfortunately rejected',
    "order.amount": "Amount",
    "orderDetails.heading": "Order details",
    "orderDetails.requestCancellation": "Request cancellation",
    "orderDetails.contactSeller": "Contact seller",
    "sheet.close": "Close",
    "app.success": "Success",
    "orderDetails.returnExchange": "Return or exchange items",
    "orderDetails.orderInfo": "Order info",
    "orderDetails.placedOn": "Placed on",
    "orderDetails.deliveredOn": "Delivered on",
    "orderDetails.paymentMethod": "Payment method",
    "orderDetails.orderAmount": "Total amount",
    "app.seeDetails": "See details",
    "orderDetails.cartTotal": "Cart total",
    "orderDetails.otherCharges": "Other charges",
    "orderDetails.deliveryCharges": "Delivery charges",
    "orderDetails.packagingCharges": "Packaging charges",
    "orderItems.heading": "Order items",
    "orderDetails.quantity": "Quantity",
    "orderDetails.price": "Price",
    "orderDetails.total": "Total",
    "orderDetails.itemDetails": "Ordered items",
    "orderDetails.returnExchangeWindow":
        "Your return/exchange window will close on",
    "contactSeller.copied": "Phone number copied",
    "contactSeller.error.info":
        "Couldn't launch the dialler. Please copy the seller number and make a call to that number"
  },
  "it": {},
};
