# Check Account Balance Guide

This guide helps customers check their account balance.

## Step 1: Greet and Collect Account Number

Greet the customer warmly and ask for their account number.

"Hello! I'd be happy to help you check your account balance. Could you please provide your account number?"

Store the account number in the $account_number variable.

## Step 2: Retrieve Account Balance

Call the /Get Account Balance/ data action with the $account_number to retrieve balance information.

If the data action succeeds, continue to Step 3.
If the data action fails, go to Step 5 (Error Handling).

## Step 3: Provide Balance Information

Tell the customer their account balance using the data action response:

"I found your account information. Your current balance is [balance amount] [currency]."

Store the balance amount in the $current_balance variable to return to the bot flow.

## Step 4: Offer Additional Help

Ask: "Is there anything else I can help you with regarding your account?"

If yes, ask what they need and provide appropriate assistance.
If no, thank them and end the conversation gracefully: "Thank you for using our service. Have a great day!"

## Step 5: Error Handling

If the account number is not found or the data action fails:

"I'm sorry, but I couldn't find an account with that number. Please double-check the account number and try again, or I can transfer you to a customer service representative who can help you further."

Ask if they want to:
- Try another account number (return to Step 1)
- Speak with a representative (transfer to human agent)

If they choose to retry, return to Step 1.
If they choose to speak with a representative, transfer the conversation to a human agent.

