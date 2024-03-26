#!/bin/bash

# Script to get information about the elements in the periodic table database 

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# if no argument is provided, print a message and exit the program

if [[ -z $1 ]]
 then
   echo -e "Please provide an element as an argument."
   exit
fi

# if an argument provided and 

# if the input argument is not a number   
if [[ ! $1 =~ ^[0-9]+$ ]]
 then
  # get the length of the argument provided
  in_len=$(echo -n "$1" | wc -m) 
  # if the input argument is greater then two letters 
  if [[ $in_len -gt 2 ]]
   then
     # retrieve data of an element by the element name 
     EDATA=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE name = '$1'")
     # if the query returns empty print a message
     if [[ -z $EDATA ]]
      then
        echo "I could not find that element in the database."
     # if the query returns an element, get the properties of the element through piping and print a message   
     else
       echo $EDATA | while IFS='|' read TYPE_ID ATOM_N SYM NAME ATOM_M MP BP TYPE
       do
         echo "The element with atomic number $ATOM_N is $NAME ($SYM). It's a $TYPE, with a mass of $ATOM_M amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
       done
     fi
  # if the argument provided has a string length <= 2 
  else
    # get data by element symbol
    EDATA=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol = '$1'")
    # if the query does return empty print a message
    if [[ -z $EDATA ]]
      then
        echo "I could not find that element in the database."
    # if the query returns an element, get the properties of the element through piping and print a message
    else
      echo $EDATA | while IFS='|' read TYPE_ID ATOM_N SYM NAME ATOM_M MP BP TYPE
      do
        echo "The element with atomic number $ATOM_N is $NAME ($SYM). It's a $TYPE, with a mass of $ATOM_M amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
      done
    fi
  fi
else
  # get element data by atomic number
  EDATA=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number = '$1'")
  # if the query returns empty print a message 
  if [[ -z $EDATA ]]
    then
      echo "I could not find that element in the database."
  # if the query by atomic_number returns an element, get the properties of the element through piping and print a message
  else
    echo $EDATA | while IFS='|' read TYPE_ID ATOM_N SYM NAME ATOM_M MP BP TYPE
    do
      echo "The element with atomic number $ATOM_N is $NAME ($SYM). It's a $TYPE, with a mass of $ATOM_M amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
    done
  fi
fi
 
