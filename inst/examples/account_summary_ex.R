# Fetch ACCOUNTS for all tags and groupName = "All", without creating
# a subscription.

req_account_summary()

# View the updated ACCOUNTS object in the treasury
treasury$ACCOUNTS

# Reset the ACCOUNTS object when you're ready
treasury$ACCOUNTS <- NULL 

# Fetch just the TotalCashValue, BuyingPower, and GrossPositionValue for
# groupName = "All", again without creating a subscription
req_account_summary(
  tags = c("TotalCashValue", "BuyingPower", "GrossPositionValue")
)

# See that the data is stored in the treasury:
treasury$ACCOUNTS

# As above, using some example $LEDGER tags:
treasury$ACCOUNTS <- NULL
req_account_summary(tags = c("TotalCashValue", "BuyingPower", "$LEDGER"))
treasury$ACCOUNTS

treasury$ACCOUNTS <- NULL
req_account_summary(tags = c("TotalCashValue", "BuyingPower", "$LEDGER:ALL"))
treasury$ACCOUNTS

################################################################################
#### Update Behavior Example: Async Mode #######################################
################################################################################

#### This example involves setting up account summary subscriptions. Make sure
#### that you actually have positions whose values are changing; i.e.,
#### accounts aren't empty, the market is currently open, etc.

## Open up a socket connection (unless you have one open already):
create_new_connections(1)

# Start an account summary subscription for the default group ("All") using
# all of the possible tags:
req_account_summary(channel = "async")

# Within three minutes of starting the subscription, take a look at the
# ACCOUNTS object in the treasury:
treasury$ACCOUNTS
# See when it was last updated:
acc_sum_update_time <- attr(treasury$ACCOUNTS, "last_updated")
acc_sum_update_time

# Soon after creating the subscription, try to update the ACCOUNTS
# object in the treasury by calling read_sock_drawer():
read_sock_drawer()

# If you're quick enough, you won't get any updated information because IB has
# not sent updated data to the socket.

# So, wait a while. For example's sake, let's wait a little over 3 minutes:
Sys.sleep(200)

# Keep calling...
read_sock_drawer()

# ...a few times, waiting 10 or 20 seconds in between calls. After 3 minutes
# have passed -- and probably before that -- you should see the
# ACCOUNTS object update.

# After updating, take a look in your treasury...
treasury$ACCOUNTS

# ...and compare your old ACCOUNTS update time -- stored in the variable
# "acct_sum_update_time" -- with your newly updated ACCOUNTS:
acc_sum_update_time
attr(treasury$ACCOUNTS, "last_updated")

# You can also take a look at the "account_summary" element of your 
# subscriptions object:
subscriptions$account_summary
subscriptions$account_summary$tags
dplyr::glimpse(subscriptions$account_summary)

# Finally, cancel the subscription. In this case, we want to cancel the one
# subscribed to the groupName "All".
cancel_account_summary("All")

# The subscription no longer appears in the subscription object:
subscriptions$account_summary

# From this point in time onward (until you create another subscription and/or
# unless there is an update on the socket left over from before you cancelled
# the subscription in this example), the account summary will no longer update
# no matter how many times you call
read_sock_drawer()
