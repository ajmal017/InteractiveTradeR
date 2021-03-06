% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/req_account_updates.R
\name{req_account_updates}
\alias{req_account_updates}
\title{Request Account Updates}
\usage{
req_account_updates(
  acctCode = "All",
  subscribe = TRUE,
  channel = NULL,
  return_data = is.null(channel) && subscribe
)
}
\arguments{
\item{acctCode}{Character vector of length 1 containing the Account ID of the account for
which updates are sought. Possible choices include any one of the elements of
the output of \link{req_managed_accts}().}

\item{subscribe}{Boolean. If TRUE, then a subscription is started and the socket passed in as
\emph{channel} will continue to receive updated account info from Interactive
Brokers every time \link{read_sock_drawer}() is called and an update is
available on the socket.}

\item{channel}{One of the following:

\itemize{
  \item \strong{Not Specified} (Default): Opens a new connection to IB, uses
  it to issue the request and retrieve the response, and closes connection
  behind itself upon completion.
  \item \strong{The Name of a Sock}: Character vector, length 1. The name of
  an open, connected socket in the \link{sock_drawer}; e.g., "master", "tws",
  or "sock_123"
  \item \strong{Numeric Client ID}: Numeric, length 1. The client ID for
  which open orders are to be retrieved; e.g., 0, 874, 123. If a client ID is
  passed, and no socket in the \link{sock_drawer} is connected on that ID,
  then a new socket will be opened on that ID, and closed upon function exit.
  \item \strong{A \code{sockconn} Connection}: An open connection object of
  class "sockconn", connected to the IB API; e.g., \code{sock_drawer$tws}
}}

\item{return_data}{Boolean of length 1. Defaults to TRUE unless argument \emph{channel} is
specified. If FALSE, data retrieved by the function will be returned as the
funciton's output. If TRUE, then a Boolean succeses flag will be returned as
the function's output indicating the success (TRUE) or failure (FALSE) of the
function's attempt to transceive data to/from IB. Data in the
\strong{\code{treasury}} is always updated regardless of the value passed as
\emph{return_data} in the function call.}
}
\value{
This function is called for its side effect of updating the
\strong{\code{treasury}}, which takes place every time the function executes.
Additionally, the function's return value depends upon the value passed in as
\emph{return_data} as follows:

\itemize{
  \item \strong{If \code{return_data == FALSE}}: A Boolean success flag,
  returned invisibly, indicating that the function executed correctly and
  updated the \strong{\code{treasury}} with any new data retrieved.
  \item \strong{If \code{return_data == TRUE}}: Any new data retrieved will
  be returned in a \link[tibble]{tibble} in addition to being added to the
  \strong{\code{treasury}}. If no new data is available, returns NULL.
}

\emph{return_data} defaults to TRUE unless \emph{channel} is specified.
}
\description{
This function either fetches or sets up a subscription to receive the data
that appear in the
"\href{https://institutions.interactivebrokers.com/en/software/tws/usersguidebook/realtimeactivitymonitoring/the_account_window.htm}{Account
Window}" window of Trader Workstation for the single account specified in the
\emph{acctCode} input. Unlike \link{req_account_updates_multi}(),
\code{req_account_updates}() can only subscribe to one account at a time.
}
\details{
\strong{Account Keys}: Several values of \emph{param} in the
\strong{ACCOUNTS} element of the output may or may not display suffixes; for
example, the \emph{param}
\strong{AccruedDividend}. The meaning of these suffixes is as follows:
\itemize{
\item "\strong{-C}": Applies to commodities
\item "\strong{-S}": Applies to stocks
\item \strong{no suffix}: Values reported are totals
}

\strong{"All" Option}: If you use a Financial Advisory (FA) account
structure, then you have the option of requesting account updates for all of
the sub-accounts that fall under the master account. To do this, append the
letter \strong{"A"} to the end of the master account's ID and pass this value
to \code{req_account_updates}() as \emph{acctCode}; for example, "F7654321A".

\strong{No "\code{cancel_}" function, use \code{subscribe = FALSE}}: Unlike
\link{req_account_summary}() and \link{req_account_updates_multi}(),
\code{req_account_updates}() does not have a companion function that cancels
the subscription. Instead, subscriptions are canceled on a socket by calling
\code{req_account_updates()} with \code{subscribe = FALSE}. See the
\strong{Examples} section below.

\strong{One account at a time / Overwriting subscriptions}: Even if you use
different sockets, IB's API protocol is set up in such a way that you may
only have one active \strong{req_account_updates}() subscription running at
any given time. If you request another subscription, the new one will simply
overwrite the old one without an error message.

\strong{Single Account}: If the user has access to only one account, then
supplying a value for \emph{acctCode} is not necessary and may be left blank
in the function call.

\strong{Time Zone}: Interactive Brokers' servers use a very simple
hour:minute formatted timestamp the response data reported by
\code{req_account_updates}() in the \emph{acct_update_time} column of the
output. The timestamp does not include a time zone because it is understood
that the times reported are denominated in terms of the time zone set by
clicking the "More Options" link in the login window of either TWS or IBG.

\strong{Cancelling subscriptions}: Use the command
\code{req_account_updates(subscribe = FALSE)}. When cancelling a subscription
made by \code{req_account_updates}() in InteractiveTradeR, any value passed
in as \emph{channel} is ignored, so it can be left out entirely. This
shortcut follows as consequence of the fact that IB only allows one
\code{req_account_updates}() subscription at a time.
}
\section{Behavior}{

IB's documentation states that subscribed socket's account updates data will
be updated \strong{every three (3) minutes} unless there is a position
change, in which case updates will be sent immediately.  However, during
market hours, you may observe much shorter, more frequent update intervals.
You can explore your actual observed update frequency by experimenting with
Example 3 in the \strong{"Examples"} section below.
}

\section{ACCOUNTS and PORTFOLIO VALUE Treasury Objects}{

  \code{req_account_updates}() updates the \strong{ACCOUNTS} and
  \strong{PORTFOLIO VALUE} objects in the \strong{\code{treasury}}. Their
  structure is set forth as follows:

\strong{ACCOUNTS}: A \link[tibble]{tibble} in which each row represents a
parameter pertaining to a particular account. Has the following columns:
\itemize{
  \item \strong{tag} <chr>: Name of account parameter, (e.g., "DayTradesRemaining")
  \item \strong{tag_value} <chr>: Value of the \emph{param} (e.g., "3")
  \item \strong{currency} <chr>: 3-letter currency abbreviation if \emph{tag_value} is a
  monetary amount, "" otherwise.
  \item \strong{account} <chr>: Account ID of the account to which the data applies.
  Included so that \emph{ACCOUNTS} data returned for different accounts can be
  combined without losing track of which account applies to which data.
}

\strong{PORTFOLIO_VALUE}: A \link{tibble} in which every row represents an asset
held in an account. Has the following columns:
\itemize{
  \item \strong{account} <chr>: Account ID of the account to which the data
  applies. Included so that \emph{PORTFOLIO_VALUE} data returned for
  different accounts can be combined without losing track of which account
  applies to which data.
  \item \strong{con_id} <chr>: Interactive Brokers' unique contract ID for
  the asset.
  \item \strong{symbol} <chr>: The exchange symbol under which the asset is
  traded, e.g., "FB", "AAPL", "IBM".
  \item \strong{sec_type} <chr>: Three-letter abbreviation for the class of
  the asset in the row, e.g., "STK", "CFD", "BOND", and so on.
  \item \strong{last_trade_date_or_contract_month} For options & futures, the
  last trading day or contract month (as applicable), in YYYYMMDD
  ("\\%Y\\%m\\%d" in R) and YYYYMM ("\\%Y\\%m" in R) format, respectively.
  \item \strong{strike} <numeric>: Strike price of asset, if applicable.
  \item \strong{right} <chr>: If applicable, the "right" parameter of a
  contract, e.g. "C" (right to buy, for a call), "P" (right to sell, put).
  \item \strong{multiplier} <dbl>: The "lot size" of a contract, if
  applicable; e.g., an options contract that affects 100 shares of
  underlying. Numeric.
  \item \strong{primary_exchange} <chr>: Main exchange on which a contract is
  traded, e.g., "NASDAQ", "NYSE".
  \item \strong{currency} <chr>: 3-letter abbreviation of the currency in
  which the contract is traded, e.g. "USD", "HKD".
  \item \strong{local_symbol} <chr>: The symbol under which the contract is
  traded in its primary exchange.
  \item \strong{trading_class} <chr>: Code that classifies an asset based on
  the manner in which it is traded. Stocks, for example, have
  \emph{trading_class} = "NMS" denoting the United States'
  \href{https://en.wikipedia.org/wiki/National_Market_System}{National Market
  System} for equities.
  \item \strong{position} <dbl>: Numeric, long or short. Denotes how many of
  the contracts are held. Don't forget \emph{multiplier}, if applicable!
  \item \strong{market_price} <numeric>: The market price of the contract on
  a per-contract basis as measured at time = \emph{acct_update_time}.
  \item \strong{market_value} <numeric>: \emph{market_price} *
  \emph{position}; i.e., market value of the account's position in a
  particular contract.
  \item \strong{average_cost} <numeric>: The effective price of the account's
  overall position in the asset, including transaction costs.
  \item \strong{unrealized_PNL} <numeric>: Equals \emph{market_value} -
  \emph{average_cost} * \emph{position} and gives the profit or loss that
  would result if the position were closed at \emph{market_price}. Does
  \strong{not} take into account transction costs of closing the position.
  \item \strong{realized_PNL} <numeric>: Gives the real-world, historical
  profit or loss earned on positions that are now closed. Includes
  transaction costs.
}
}

\examples{
# Clear out the treasury, sock drawer, and subscriptions
clean_slate()

####
#### Example 1: Fetch account update for one account
####

# Pick a random account for this example or specify one yourself,
#   e.g., acct <- "DU1234567"
acct <- sample(req_managed_accts(), 1)
acct

# Fetch account updates for the account, without starting a subscription
req_account_updates(acct)

# Print the ACCOUNTS
treasury$ACCOUNTS

# Print the PORTFOLIO_VALUE
treasury$PORTFOLIO_VALUE # empty list if no positions

####
#### Example 2: Fetch account update data for many accounts
####

clean_slate() # clean slate (optional)

treasury$ACCOUNTS      # should return NULL
treasury$PORTFOLIO_VALUE # should return NULL

# Fetch account updates for all of your accounts using the walk() function
# from the purrr package:
req_managed_accts() \%>\%
  purrr::walk(
    function(account){
      # Sys.sleep(1/50)
      req_account_updates(acctCode = account)
    }
  )

# Uncomment the "Sys.sleep(1/50)" to pause execution for one fiftieth of a
# second between each call to req_account_updates(). The reason you may want
# to do this is that Interactive brokers only allows, at max, 50 API calls per
# second. If you have more than 50 accounts and a fast computer & connection,
# the "Sys.sleep(1/50)" prevents you from exceeding the limit.

# Check that all accounts are represented in ACCOUNTS:
identical(
  sort(unique(treasury$ACCOUNTS$account)),
  sort(req_managed_accts())
)

####
#### Example 3: Persistent account update subscriptions
####

# To create an ongoing subscription that continuously collects account
# updates, make the same calls to req_account_updates() as above, but use a
# persistent socket.

clean_slate() # clean slate, optional

treasury$ACCOUNTS        # should return NULL
treasury$PORTFOLIO_VALUE # should return NULL

# Open up a socket
create_new_connections(1)

# Pick pick two random accounts, or replace the "sample()" with an account code
# (e.g., "DU7654321") as desired.
acct2 <- sample(req_managed_accts(), 2)

# Make the call, this time with channel = "async"
acct2 \%>\%
  purrr::walk(
    function(account){
      req_account_updates(account, channel = "async")   
    }
  )


# Within three minutes of starting the subscription, take a look at the
# ACCOUNTS and PORTFOLIO_VALUE objects in the treasury:
treasury$ACCOUNTS
treasury$PORTFOLIO_VALUE
# See when they were last updated:
acc_val_update_time  <- attr(treasury$ACCOUNTS, "last_updated")
acc_val_update_time
port_val_update_time <- attr(treasury$PORTFOLIO_VALUE, "last_updated")
port_val_update_time

# Soon after creating the subscription, try to update the treasury objects by
# calling read_sock_drawer():
read_sock_drawer()

# If you're quick enough, you won't get any updated information because IB has
# not sent updated data to the socket.

# Note that you now have an "account_updates" entry in subscriptions for the
# account you're now following:
subscriptions$account_updates

# Wait a little over 3 minutes
Sys.sleep(200)

# Keep calling...
read_sock_drawer()
# ...a few times, waiting 10 or 20 seconds in between calls. After 3 minutes
# have passed -- but probably before that -- you should see either or both of
# the ACCOUNTS and PORTFOLIO_VALUE objects update.

# After updating, take a look in the treasury:
treasury$ACCOUNTS
treasury$PORTFOLIO_VALUE

# And compare update times:
acc_val_update_time
attr(treasury$ACCOUNTS,"last_updated")

port_val_update_time
attr(treasury$PORTFOLIO_VALUE, "last_updated")

#### Example 4: Cancelling Subscriptions

# Cancel the subscription created in Example 3 with:
req_account_updates(acct2, subscribe = FALSE)

}
\seealso{
Other treasury: 
\code{\link{cancel_account_summary}()},
\code{\link{cancel_account_updates_multi}()},
\code{\link{req_account_summary}()},
\code{\link{req_account_updates_multi}()}
}
\concept{treasury}
