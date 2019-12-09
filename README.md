# Final Project: Pong Game

Final project for CS-373 Digital Logic Design, taught by Kent Jones.

##  Group Members: 
Lauren Barry and Karen Sobtafo

## Project Description
Our project is to create a pong game that is displayed using VGA. We plan to implement a moving ball and paddle to begin with, including collisions. We also plan to implement two player gameplay, with two paddles. Each player would use buttons on the board to control their respective paddle. Scoring would be displayed on the 7-segment display.  

## List of requirements (ranked from easy to hard)
* Setup RGB VGA output 
* Calculate ball dimensions using outer bounds (ball_ xl, ball_xr, ball_yt, ball_yb) 
* Calculate paddle 1’s dimensions using bounds (paddle_xl, paddle_xr, paddle_yt, paddle_yb) * Calculate the speed and direction of the ball and paddle
* Set the RGB colors for the background, ball, and paddle 
* Update/display the positions of the ball and paddle 
* Add button controls to paddle 1 using onboard buttons 
* Add a 2nd paddle 
    * Calculate paddle 2’s dimensions using bounds (paddle2_xl, paddle2_xr, paddle2_yt, paddle2_yb) 
    * Add button controls for paddle 2 
* Detecting when a player has scored (when the ball hits either the top or bottom of the screen) 
* Displaying each player’s score on the 7-segment display 

## High level hardware block diagram for the application. 
In-Progress.