#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=bikes --tuples-only -c"
echo -e "\n~~~~~ Bike Rental Shop ~~~~~\n"
MAIN_MENU() {
    if [[ $1 ]] 
    then 
        echo -e "\n$1"
    fi
    echo How may I help you?
    echo -e "\n1. Rent a bike\n2. Return a bike\n3. Exit"
    read MAIN_MENU_SELECTION
    case $MAIN_MENU_SELECTION in
        1) RENT_MENU ;;
        2) RETURN_MENU ;;
        3) EXIT ;;
        *) MAIN_MENU "Please enter a valid option." ;;
    esac
}
RENT_MENU() {
# get available bikes
AVAILABLE_BIKES=$($PSQL "SELECT bike_id, type, size FROM bikes WHERE available = TRUE ORDER BY bike_id")

# if no bikes available
if [[ -z $AVAILABLE_BIKES ]]
then
    # send to main menu
    MAIN_MENU "Sorry, we don't have any bikes available right now."
else
    # display available bikes
    echo -e "\nHere are the bikes we have available:"
    echo "$AVAILABLE_BIKES" | while read BIKE_ID BAR TYPE BAR SIZE 
        do 
            echo "$BIKE_ID) $SIZE\" $TYPE Bike"
        done
    # ask for bike to rent
    echo -e "\nWhich one would you like to rent?"
    read BIKE_ID_TO_RENT
    # if input is not a number
    if [[ ! $BIKE_ID_TO_RENT =~ ^[0-9]+$ ]]
    then
    # send to main menu
       MAIN_MENU "That is not a valid bike number." 
    else
    # get bike availability
    BIKE_AVAILABILITY=$($PSQL "SELECT available FROM bikes WHERE bike_id = $BIKE_ID_TO_RENT AND available = TRUE")
    
    # if not available
        if [[ -z $BIKE_AVAILABILITY ]]
        then
        # send to main menu
            MAIN_MENU "That bike is not available."
        else
        # get customer info
        echo -e "\nWhat's your phone number?"
        read PHONE_NUMBER
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$PHONE_NUMBER'")
        # if customer doesn't exist
            if [[ -z $CUSTOMER_NAME ]]
            then
            # get new customer name
                echo -e "\nWhat's your name?"
                read CUSTOMER_NAME
            # insert new customer
                INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$PHONE_NUMBER', '$CUSTOMER_NAME')")
                        
            fi
            # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$PHONE_NUMBER'")
        # insert bike rental
        INSERT_RENTAL_RESULT=$($PSQL "INSERT INTO rentals(customer_id, bike_id) VALUES('$CUSTOMER_ID', '$BIKE_ID_TO_RENT')")
        # set bike availability to false
        SET_TO_FALSE_RESULT=$($PSQL "UPDATE bikes SET available = FALSE where bike_id = $BIKE_ID_TO_RENT")
        # get bike info
        BIKE_INFO=$($PSQL "SELECT size, type FROM bikes WHERE bike_id = $BIKE_ID_TO_RENT")
        echo $BIKE_INFO
        # send to main menu
        fi
    
    fi
    
fi
}
RETURN_MENU() {
    echo Return Menu
}
EXIT() {
    echo -e "\nThank you for stopping in.\n"
}
MAIN_MENU 

