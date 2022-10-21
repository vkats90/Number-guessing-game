#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=users --no-align --tuples-only -c"

NUMBER=$(( $RANDOM % 1000 + 1 ))

echo -e "\nEnter your username:"
read USERNAME

USERID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ ! -z $USERID ]] 
then
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" | echo 
  GAMES_PLAYED=0
  BEST_GAME=0
fi
echo -e "\nGuess the secret number between 1 and 1000:"

GUESSES() {
  read GUESS
  COUNTER=$(( $1 + 1 ))

  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:\n"
    GUESSES $COUNTER
  fi

  if [[ $GUESS = $NUMBER ]]
  then 
    echo -e "\nYou guessed it in $COUNTER tries. The secret number was $GUESS. Nice job!"
    $PSQL "UPDATE users SET games_played='$(( $GAMES_PLAYED + 1 ))' WHERE username='$USERNAME'" | echo
    if [[ $COUNTER < $BEST_GAME || $BEST_GAME = 0 ]]
    then
      $PSQL "UPDATE users SET best_game='$COUNTER' WHERE username='$USERNAME'" | echo
    fi
  elif [[ $GUESS > $NUMBER ]]
  then
    echo -e "It's lower than that, guess again:\n"
    GUESSES $COUNTER
  elif [[ $GUESS < $NUMBER ]]
  then
    echo -e "It's higher than that, guess again:\n"
    GUESSES $COUNTER
  fi
}

GUESSES
