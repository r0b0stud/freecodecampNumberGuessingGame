#!/bin/bash
RANDOM_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0
CHECK=0
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
CHECK_NUMBERS()
{
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
  if ! [[ $1 =~ ^[0-9]+$ ]]
  then
  echo "That is not an integer, guess again:"
  read SECRET_NUMBER
  CHECK_NUMBERS $SECRET_NUMBER
  fi
  if [[ $1 == $RANDOM_NUMBER ]]
  then
  INSERT_IN_GAMES_TABLE=$($PSQL "INSERT INTO games(username,try_number) VALUES ('$USERNAME',$NUMBER_OF_GUESSES)")
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
  elif [[ $1 > $RANDOM_NUMBER ]]
  then
  echo "It's lower than that, guess again:"
  read SECRET_NUMBER
  CHECK_NUMBERS $SECRET_NUMBER
  else
  echo "It's higher than that, guess again:"
  read SECRET_NUMBER
  CHECK_NUMBERS $SECRET_NUMBER
  fi
}
START_GAME()
{
  if [[ $CHECK -eq 0 ]]
  then
  echo "Guess the secret number between 1 and 1000:"
  CHECK=$(($CHECK+1))
  fi
  read SECRET_NUMBER
  if ! [[ $SECRET_NUMBER =~ ^[0-9]+$ ]]
  then
  echo "That is not an integer, guess again:"
  START_GAME
  else
  CHECK_NUMBERS $SECRET_NUMBER
  fi
}
echo "Enter your username:"
read USERNAME
USERNAME_FROM_DB=$($PSQL "SELECT username FROM players WHERE username = '$USERNAME'")
if [[ -z $USERNAME_FROM_DB ]]
then
echo "Welcome, $USERNAME! It looks like this is your first time here."
#add username to db
INSERT_IN_PLAYERS_TABLE=$($PSQL "INSERT INTO players(username) VALUES ('$USERNAME')")
else
MIN_TRY_NUMBER=$($PSQL "SELECT MIN(try_number) FROM games WHERE username = '$USERNAME'")
NUMBER_OF_GAMES=$($PSQL "SELECT COUNT(*) FROM games WHERE username = '$USERNAME'")
echo "Welcome back, $USERNAME! You have played $NUMBER_OF_GAMES games, and your best game took $MIN_TRY_NUMBER guesses."
fi
START_GAME
