################################################################################
#### Effect of ledgerAndNLV ####################################################
################################################################################

# Let's look at the difference between calling req_account_updates_multi with
#  ledgerAndNLV = TRUE vs. setting it to FALSE.

#1) Fetch an update using req_account_updates_multi()'s default values for 
#   for account and ledgerAndNLV ("ALL" and TRUE, respectively).
req_account_updates_multi()

# The update printed to screen but it's not lost -- it's in the treasury. 

# 2) Save the treasury object in a variable to use for comparing later:
aum_true <- treasury$ACCOUNTS

# 3) Clear out the treasury. Without this step, InteractiveTradeR would update
# the new ACCOUNTS object when we call req_account_updates_multi() again with
# ledgerAndNLV = FALSE, making it hard to tell exactly what effect our changing
# of the value of ledgerAndNLV had.
clean_slate()

# Call req_account_updates_multi() again, but with ledgerAndNLV = FALSE:
req_account_updates_multi(ledgerAndNLV = FALSE)
aum_false <- treasury$ACCOUNTS

# Compare the two:
#   3.1) Same account:
unique(aum_true$account)
unique(aum_false$account)
#   3.2) See that ledger_and_NLV = FALSE includes more parameters:
setdiff(unique(aum_false$tag), unique(aum_true$tag))

################################################################################
#### Subscriptions #############################################################
################################################################################

# Clean slate
clean_slate()

# Open a socket
create_new_connections()

# Fetch the account IDs of your six paper trading accounts and use walk() from
# the purrr package to subscribe to each one
req_managed_accts() %>%
  purrr::walk(
    req_account_updates_multi,
    channel = "async"
  )

# Verify that you're now subscribed to the six paper trading accounts:
subscriptions$account_updates_multi

# Access the retrieved updates:
treasury$ACCOUNTS

# You should have all six paper account codes represented in the "account"
# column of the ACCOUNTS treasury object.

# This information will update every 3 minutes -- and probably more frequently
# than that in practice -- for those accounts that have positions in financial
# instruments. You can wait for at least one cycle and call read_sock_drawer()
# again to see this for yourself.

# Save the treasury object to use for comparing later
before_cancel <- treasury$ACCOUNTS

# When you're ready, cancel a subscription or two: how about the 1st and 3rd?
cancel_accounts <- subscriptions$account_updates_multi$req_name[c(1,3)]
cancel_account_updates_multi(cancel_accounts)

# Check that the two accounts are indeed removed from subscriptions:
subscriptions$account_updates_multi
any(cancel_accounts %in% subscriptions$account_updates_multi$req_name)

# From this point on, the sock drawer will no longer get updated data for the
# two accounts that were unsubscribed.

# To convince yourself, first read off any data that might have gotten sent
# in the time between the last read and the call to cancel:
read_sock_drawer()

# From this point on, the canceled accounts' treasury data -- which can be
# selected using the following code:
treasury$ACCOUNTS %>%
  dplyr::filter(account %in% cancel_accounts)
# -- will not update, no matter how many times you call read_sock_drawer(),
# unless you subscribe to them again.

################################################################################
#### CANCELLING Subscriptions ##################################################
################################################################################

# Clear out the treasury & subscriptions for this example
clean_slate(c("treasury", "subscriptions"))

# Open a socket
create_new_connections()

# Fetch the account IDs of your six paper trading accounts and use walk() from
# the purrr package to subscribe to each one
req_managed_accts() %>%
  purrr::walk(
    req_account_updates_multi,
    channel = "async"
  )

# Verify that you're now subscribed to the six paper trading accounts:
subscriptions$account_updates_multi

# Access the retrieved updates:
treasury$ACCOUNTS

# You should have all six paper account codes represented in the "account"
# column of the ACCOUNTS treasury object.

# This information will become available every 3 minutes -- and probably more
# frequently than that in practice -- for those accounts that have positions in
# financial instruments. 

# You can wait for at least one cycle and see this for yourself; just call
# read_sock_drawer() as many times as you'd like to refresh the data.

# Save the treasury object to use for comparing later
before_cancel <- treasury$ACCOUNTS

# When you're ready, cancel a subscription or two: how about the 1st and 3rd?
cancel_accounts <- subscriptions$account_updates_multi$req_name[c(1,3)]
cancel_account_updates_multi(cancel_accounts)

# Check that the two accounts are indeed removed from subscriptions:
subscriptions$account_updates_multi
any(cancel_accounts %in% subscriptions$account_updates_multi$req_name)

# From this point on, the sock drawer will no longer get updated data for the
# two accounts that were unsubscribed.

# To convince yourself, first read off any data that might have gotten sent
# in the time between the last read and the call to cancel:
read_sock_drawer()

# From this point on, the canceled accounts' treasury data -- which can be
# selected using the following code:
treasury$ACCOUNTS %>%
  dplyr::filter(account %in% cancel_accounts)
# -- will not update, no matter how many times you call read_sock_drawer(),
# unless you subscribe to them again.
