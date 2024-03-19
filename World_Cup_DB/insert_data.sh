#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Script to add contents from the games.csv file to teams and games table

echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WGOALS OGOALS
do
  if [[ $YEAR != 'year' ]]
    then
      # get winner and opponent teams

      WINNER_T=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
      OPPONENT_T=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")

      if [[ -z $WINNER_T || -z $OPPONENT_T ]]
        then
          INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
          INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
          if [[ $INSERT_WINNER == 'INSERT 0 1' || $INSERT_OPPONENT == 'INSERT 0 1' ]]
            then 
              echo Winner and opponents are inserted into teams, $WINNER, $OPPONENT
          fi
      fi
      
      W_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      
      if [[ -n $W_ID || $O_ID ]]
        then
          INSERT_GAMES=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$W_ID', '$O_ID', '$WGOALS', '$OGOALS')")
          if [[ $INSERT_GAMES == 'INSERT 0 1' ]]
            then 
               echo Game is inserted into games table
          fi
      fi  
  fi
done
