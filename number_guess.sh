#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guessing_game_users --tuples-only -c"

echo "Enter your username:"
USER_NAME(){
  if [[ $1 ]];then
  echo $1
  echo "Enter your username:"
  fi
read USERNAME
USER_NAME_LENGTH=${#USERNAME}
if [[ $USER_NAME_LENGTH -gt 22 ]];then
USER_NAME "Username can only be 22 characters long"
fi
}
USER_NAME
GET_USERNAME=$($PSQL "SELECT user_name FROM users WHERE user_name = '$USERNAME'" | sed 's/ //g')
if [[ -z $GET_USERNAME ]]; then
echo "Welcome, $USERNAME! It looks like this is your first time here."
CREATE_NEW_USER=$($PSQL "INSERT INTO users(user_name) VALUES('$USERNAME')")
else
GET_USER_GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_name = '$USERNAME'" | sed 's/ //g')
GET_USER_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_name = '$USERNAME'" | sed 's/ //g')
echo $GET_USER_BEST_GAME
echo "Welcome back, $GET_USERNAME! You have played $GET_USER_GAMES_PLAYED games, and your best game took $GET_USER_BEST_GAME guesses."
fi
RANDOM_NUMBER=$((1 + RANDOM % 1000))

GUESS_FUNCTION(){
  
  if [[ -z $1 ]];then
  echo "Guess the secret number between 1 and 1000:"
  else
  echo $1
  COUNT=$(( $COUNT+1 ))
  fi
  GUESS_CHECK(){
    if [[ $1 ]];then
    echo $1
    fi
  read GUESSED_NUMBER
  if [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]];then
  GUESS_CHECK "That is not an integer, guess again:"
  fi
  }
  GUESS_CHECK
  if (( $GUESSED_NUMBER == $RANDOM_NUMBER ));then
  ACTUAL_COUNT=$(( $COUNT+1 ))
  echo "You guessed it in $ACTUAL_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_name = '$USERNAME'")
  BEST_GAME_CHECK=$($PSQL "SELECT best_game FROM users WHERE user_name = '$USERNAME'")
  if (( $COUNT < $BEST_GAME_CHECK || $BEST_GAME_CHECK == 0 ));then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $COUNT + 1 WHERE user_name = '$USERNAME'")
  fi
  else
  if (( $GUESSED_NUMBER > $RANDOM_NUMBER ));then
  GUESS_FUNCTION "It's lower than that, guess again:" 
  else 
  if (( $GUESSED_NUMBER < $RANDOM_NUMBER ));then
  GUESS_FUNCTION "It's higher than that, guess again:"
  fi 
  fi
  fi 
  
}
GUESS_FUNCTION