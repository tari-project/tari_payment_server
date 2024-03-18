Feature: Order matching
  Background:
    Given a fresh install

  Scenario: A customer can submit orders
    When I receive an order with id 100 from customer 'alice101' for 56 XTR
    Then the account for customer 'alice101' exists
    Then the account for customer 'alice101' has total orders of 56 XTR
    When I receive an order with id 101 from customer 'alice101' for 44 XTR
    Then the account for customer 'alice101' has total orders of 100 XTR

  Scenario: Receiving a payment with a new public key will create a new account
    When I receive a wallet payment with txid [tari_tx1] from '🏦🍟🎵🐸🏁🔭📝👠🍈🌻🐚🍞🐓🌝👞🐢📌🍔🎤🚨🍣🐀😿💸💡🎁😉🍉🎃🐳🌷🎢👓' for 100 XTR
    Then the account for address '🏦🍟🎵🐸🏁🔭📝👠🍈🌻🐚🍞🐓🌝👞🐢📌🍔🎤🚨🍣🐀😿💸💡🎁😉🍉🎃🐳🌷🎢👓' exists
    Then the account for address '🏦🍟🎵🐸🏁🔭📝👠🍈🌻🐚🍞🐓🌝👞🐢📌🍔🎤🚨🍣🐀😿💸💡🎁😉🍉🎃🐳🌷🎢👓' has total received of 100 XTR
    Then the account for address '🏦🍟🎵🐸🏁🔭📝👠🍈🌻🐚🍞🐓🌝👞🐢📌🍔🎤🚨🍣🐀😿💸💡🎁😉🍉🎃🐳🌷🎢👓' has total pending of 100 XTR
    Then the account for address '🏦🍟🎵🐸🏁🔭📝👠🍈🌻🐚🍞🐓🌝👞🐢📌🍔🎤🚨🍣🐀😿💸💡🎁😉🍉🎃🐳🌷🎢👓' has current balance of 0 XTR
    When payment [tari_tx1] confirms
    Then the account for address '🏦🍟🎵🐸🏁🔭📝👠🍈🌻🐚🍞🐓🌝👞🐢📌🍔🎤🚨🍣🐀😿💸💡🎁😉🍉🎃🐳🌷🎢👓' has total received of 100 XTR
    Then the account for address '🏦🍟🎵🐸🏁🔭📝👠🍈🌻🐚🍞🐓🌝👞🐢📌🍔🎤🚨🍣🐀😿💸💡🎁😉🍉🎃🐳🌷🎢👓' has current balance of 100 XTR
    Then the account for address '🏦🍟🎵🐸🏁🔭📝👠🍈🌻🐚🍞🐓🌝👞🐢📌🍔🎤🚨🍣🐀😿💸💡🎁😉🍉🎃🐳🌷🎢👓' has total pending of 0 XTR

  Scenario: An order update changing the total price will update the user's total_orders balance
    When I receive an order with id 200 from customer 'charlie101' for 25 XTR
    When I receive an order with id 201 from customer 'charlie101' for 15 XTR
    Then the account for customer 'charlie101' has total orders of 40 XTR
    When order 200 is updated with total_price of '30'
    Then the account for customer 'charlie101' has total orders of 45 XTR
    Then the order with id 200 has total_price of '30'

  Scenario: Cancelling an order will update the user's total_orders balance
    When I receive an order with id 300 from customer 'dave101' for 250 XTR
    Then the account for customer 'dave101' has total orders of 250 XTR
    When order 300 is updated with status of 'Cancelled'
    Then the account for customer 'dave101' has total orders of 0 XTR

  Scenario: Cancelling a payment will update the user's total_received and current_balance
    When I receive a wallet payment with txid [tari_tx1] from '6829578d62ddcba2191178287307a07dc8244af92b6bebc2b83ee41a40880e4897' for 1000 XTR
    Then the account for address '6829578d62ddcba2191178287307a07dc8244af92b6bebc2b83ee41a40880e4897' has total received of 1000 XTR
    Then the account for address '6829578d62ddcba2191178287307a07dc8244af92b6bebc2b83ee41a40880e4897' has total pending of 1000 XTR
    Then the account for address '6829578d62ddcba2191178287307a07dc8244af92b6bebc2b83ee41a40880e4897' has current balance of 0 XTR
    When payment [tari_tx1] is cancelled
    Then the account for address '6829578d62ddcba2191178287307a07dc8244af92b6bebc2b83ee41a40880e4897' has total received of 0 XTR
    Then the account for address '6829578d62ddcba2191178287307a07dc8244af92b6bebc2b83ee41a40880e4897' has current balance of 0 XTR


  Scenario: A customer can order and pay for an item
    When I receive an order with id 200 from customer 'bob' for 62 XTR
    When I receive a wallet payment with txid [tari_tx2] from '6829578d62ddcba2191178287307a07dc8244af92b6bebc2b83ee41a40880e4897' for 65 XTR and memo "order id: [200]"
    Then the account for address '6829578d62ddcba2191178287307a07dc8244af92b6bebc2b83ee41a40880e4897' has total received of 65 XTR
    When payment [tari_tx2] confirms
    Then the account for customer 'bob' has total orders of 62 XTR
    Then the account for customer 'bob' has total received of 65 XTR
    Then the account for customer 'bob' has current balance of 3 XTR
    Then the account for customer 'bob' has total pending of 0 XTR
    Then the order with id 200 has status of 'Paid'

