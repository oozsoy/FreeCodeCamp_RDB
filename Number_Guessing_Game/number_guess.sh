#!/bin/bash

# ~~~ NUMBER GUESSING GAME ~~~

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# get username from the user
echo "Enter your username:"
read USERNAME

# query that username in the databe
USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

# if user do not exist in the DB
if [[ -z $USER ]]
  then
    # Greet the new user
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    # insert the new_user to the DB
    INSERT_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # if user already existing, get users info and greet the user
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USER'")
  TOT_GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT COALESCE(min(n_of_guesses),0) FROM games WHERE user_id = $USER_ID")

  echo "Welcome back, $USER! You have played $TOT_GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# generate a random number between 1 and 1000
RAND_NUM=$((1 + RANDOM % 1000))
# Number of guesses it took to win the game
NUM_OF_GUESSES=0
# a default value for the user guess to initiate the while loop below
USER_GUESS=-1

# ask the user to guess the number
echo "Guess the secret number between 1 and 1000:" 

while [[ $RAND_NUM != $USER_GUESS ]];
do
  # ask the user to guess a number
  read USER_GUESS

  # if the user guess is not an integer between 1 and 1000
  if [[ ! "$USER_GUESS" =~ ^[0-9]+$ ]] 
    then
      # Prompt the user to give a valid int number
      echo "That is not an integer, guess again:"    
  else
    ((NUM_OF_GUESSES++)) # increment the NUM_OF_GUESSES variable at each wrong guess
    # check the guess relative to the random number
    # if correct 
    if (( $USER_GUESS == $RAND_NUM ))
      then
        # Congratulate the user with the information about the game
        echo "You guessed it in $NUM_OF_GUESSES tries. The secret number was $RAND_NUM. Nice job!"
        # get user_id of the player to insert the game info into games table and update users table
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
        INSERT_GT=$($PSQL "INSERT INTO games(user_id, n_of_guesses) VALUES($USER_ID, $NUM_OF_GUESSES)")
        UPDATE_UT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id = $USER_ID")
        break
    # if the guess is smaller than the rand number
    elif (( $USER_GUESS < $RAND_NUM ))
      then
        # tell the user to go up
        echo "It's higher than that, guess again:"
    else
      # otherwise tell the user to go down
      echo "It's lower than that, guess again:"
    fi
  fi
done

