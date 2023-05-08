#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
LIST_OF_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to my salon, how can I help you?\n"

MAIN_MENU () {
if [[ $1 ]]
then
  echo -e "\n$1\n"
fi  
echo "$LIST_OF_SERVICES" | while read SERVICE_ID BAR NAME
do
 echo "$SERVICE_ID) $NAME"
done
read SERVICE_ID_SELECTED
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
  MAIN_MENU "That is not a valid number"
else
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    CUSTOMER_IDENTIFICATION
  fi
fi
}
CUSTOMER_IDENTIFICATION(){
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  if [[ ! $CUSTOMER_PHONE =~ [0-9]{3}-[0-9]{3}-[0-9]{4} ]]
  then
    echo "Not valid number"
    CUSTOMER_IDENTIFICATION
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_INTO_CUSTOMERS=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi 
  APPOINTMENT 
    }
APPOINTMENT(){
  echo -e "\nWhat time would you like to$SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  INSERT_INTO_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have to put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."
 }
MAIN_MENU
