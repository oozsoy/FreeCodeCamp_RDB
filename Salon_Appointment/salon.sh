#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcome to Effortless Glam! ~~~~~\n"

MAIN_MENU()
{
if [[ $1 ]]
  then
    echo -e "\n$1"
fi

SERVICES=$($PSQL "SELECT service_id, name FROM services")
echo "$SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done
read SERVICE_ID_SELECTED

 case $SERVICE_ID_SELECTED in
 1) SERVICE_MENU ;;
 2) SERVICE_MENU ;;
 3) SERVICE_MENU ;;
 4) SERVICE_MENU ;;
 5) SERVICE_MENU ;;
 *) MAIN_MENU "I could not find that service. What would you like today?\n" ;;
 esac
}

SERVICE_MENU()
{
  # get name of the service selected
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo -e "\nGreat, you would like to get a$SERVICE_NAME"
  # get customer phone number
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE

  CHECK_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CHECK_PHONE ]]
    then
      # get customer name
      echo -e "\nWe don't have your record it seems. What's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      echo -e "\nWhat time would you like to get your$SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      #insert appointment for the new customer
      N_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      INSERT_NC_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($N_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

  else
    # get customer name in the DB
    CUSTOMER_NAME_DB=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like to get your$SERVICE_NAME,$CUSTOMER_NAME_DB?"
    read SERVICE_TIME

    #insert appointment for the existing customer
    E_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    INSERT_EC_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($E_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME_DB."
  fi
}

MAIN_MENU
