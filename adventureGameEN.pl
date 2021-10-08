/*i_am_at/1 -> So we know where are we at, at any moment */
/*at/2 -> So we know where the items are */
/*holding/1 -> So we know what items the player is holding */
/*car_door/1 -> So we know if the car door is closed or opened */
/*gas_station_door/1 -> So we know if the gas station door is closed or opened */

:- dynamic i_am_at/1, at/2, holding/1, car_door/1, gas_station_door/1. /* For SWI-Prolog. */

/* Used for the removal of fact or clause of our dynamic database so it is ready for a new game */

:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(car_door(_)), retractall(gas_station_door(_)), retractall(holding(_)).

/* We use assert which inserts data to the database such as what items we hold, the situation of the doors etc.*/

/* We start with both doors closed.*/

car_door(closed).
gas_station_door(closed).


/* We set the starting point of player. */

i_am_at(car).


/* We set the starting items of player */

holding(money).


/* We set how the places connect */

/* The car door must be opened in order for the player to go out */
path(car, road) :- car_door(open).

path(car, road) :- car_door(closed),
		   write("You need to open the car door first!"), nl,
       		   !, fail.

/* The gas station door must be opened for the player to go inside */
path(road, gas_station) :- gas_station_door(open).

path(road, gas_station) :- gas_station_door(closed),
			   write("You need to open the gas station door first!"), nl,
       		   	   !, fail.

/* The car door must be opened for the player to get in */
path(road, car) :- car_door(open).

path(road, car) :- car_door(closed),
		   write("You need to open the car door first!"), nl,
       		   !, fail.

/* The gas station door must be opened for the player to leave */


path(gas_station, road) :- gas_station_door(closed),
			   write("You need to open the gas station door first!"), nl,
       		   	   !, fail.


/* As the player cannot leave without paying, we have these cases.*/

/* If the player has the money and no goal items,then it is fine.*/

path(gas_station, road) :- not(holding(soda)), not(holding(newspaper)),holding(money).

/*If the player has the goal items and no money then we are fine, it means they paid. */

path(gas_station, road) :- holding(soda), holding(newspaper),not(holding(money)).

/* If the player has one of the goal items or two AND the money, it means they didn't pay thus cannot leave.*/

path(gas_station, road) :- holding(soda), holding(money),
	write("You need to pay first!"), nl,
        !, fail.

path(gas_station, road) :- holding(newspaper), holding(money),
	write("You need to pay first!"), nl,
        !, fail.

path(gas_station, road) :- holding(soda), holding(newspaper), holding(money),
	write("You need to pay first!"), nl,
        !, fail.

path(gas_station, road) :- gas_station_door(open).


/* Player cannot go somewhere they are already at.*/
path(X,X) :- write("You are already there."), nl,
        !, fail.

/* For the rest of the cases.*/
path(_,_) :- write("You can't get there from here."), nl,
        !, fail.


/* We set the positions of the goal items.*/

at(soda, gas_station).
at(newspaper, gas_station).


/* The player gets a goal item into inventory. */

/* If the player already posses it.*/
take(X) :-
        holding(X),
        write("You're already holding it!"),
        !, nl.

/* If the player obtains it successfuly.*/
take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        assert(holding(X)), 
        write("You take the "),write(X),
        !, nl.

/* If the items is not where the player is trying to grab it at.*/
take(_) :-
        write("I don't see it here."),
        nl.

/* Player goes to another place as long as the places are connected. */

goto(There) :-
        i_am_at(Here),
        path(Here, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        look, !.


/* Describe the whereabouts of the new place.*/

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
        nl.


/* Show in a loop (with 'fail' for backtracking) all the items that are in the same place as the player.*/

notice_objects_at(Place) :-
      			  at(X, Place),
     			  write("There is a "), write(X), write(" here."), nl,
      			  fail.

/* If there are no items.*/
notice_objects_at(_).


/* Player pays the salesman with the item "money"*/
/* We say that the player can only pay with money and the item "money" is exchanged once for the goal items without change.*/
/* There are cases where the transaction is not successful.*/

pay_with(money) :-
		holding(money),
		holding(soda),
		holding(newspaper),
       	 	i_am_at(gas_station),
        	retract(holding(money)),
       	 	write("You have paid the cashier for the soda and the newspaper."),
		write("He thanks you and wishes you happy holidays."),
       	 	nl, !.

/* If player has already paid. */
pay_with(money) :-
		not(holding(money)),
		holding(soda),
		holding(newspaper),
       	 	i_am_at(gas_station),
       	 	write("You already paid the man!"),
       	 	nl, !.

/* If player possess only one goal item. */
pay_with(money) :-
		holding(money),
		(not(holding(soda));
		not(holding(newspaper))),
       	 	i_am_at(gas_station),
       	 	write("You don't have everything you want to buy!"),
       	 	nl, !.

/* If player is not at the gas station. */		
pay_with(money) :-
       	 	not(i_am_at(gas_station)),
       	 	write("You are not in the gas station!"),
       	 	nl, !.


/* Player opens car door. */	
/* and remains open until closed. */	
open(car_door) :-
		(i_am_at(car); i_am_at(road)),
		car_door(closed),
		retract(car_door(closed)),
		assert(car_door(open)),
		write("You have opened the car door."),
       	 	nl, !.


/* If player is not in the car or near it (we say that while in place "road" the player)
can interact with both doors (car, gas station). */
open(car_door) :-
		not((i_am_at(car); i_am_at(road))),
		write("You need to be inside or near the car,to open the car door."),
       	 	nl, !.
	
/* If the car door is opened already, it cannot be opened again. */	
open(car_door) :-
		car_door(open),
		write("The car door is already open."),
       	 	nl, !.	



/* Player opens gas station door. */	
/* and it remains open until closed. */	
open(gas_station_door) :-
			(i_am_at(gas_station); i_am_at(road)),
			gas_station_door(closed),
			retract(gas_station_door(closed)),
			assert(gas_station_door(open)),
			write("You have opened the gas station door."),
       	 		nl, !.


/* If not near gas station or inside, player cannot open door.*/	
open(gas_station_door) :-
		not((i_am_at(gas_station); i_am_at(road))),
		write("You need to be inside or near the gas station, to open the gas station door."),
       	 	nl, !.
	

/*If already opened, cannot open gas station door again.*/		
open(gas_station_door) :-
		gas_station_door(open),
		write("The gas station door is already open."),
       	 	nl, !.	

	
/* General case where the player tries to open something else.*/
open(_) :-
		write("You can't open that."),
       	 	nl, !.	


/* Closes car door. */	
/* and remains closed until opened*/	
closeit(car_door) :-
		(i_am_at(car); i_am_at(road)),
		car_door(open),
		retract(car_door(open)),
		assert(car_door(closed)),
		write("You have closed the car door."),
       	 	nl, 
		!.

/* If not near car door or inside car, cannot close it.*/	
closeit(car_door) :-
		not((i_am_at(car); i_am_at(road))),
		write("You need to be inside or near the car,to close the car door."),
       	 	nl, 
		!.
	
/* If car door already closed, cannot close it again.*/		
closeit(car_door) :-
		car_door(closed),
		write("The car door is already closed."),
       	 	nl, 
		!.	

/* Close gas station door. */	
/* remains closed. */
closeit(gas_station_door) :-
			(i_am_at(gas_station); i_am_at(road)),
			gas_station_door(open),
			retract(gas_station_door(open)),
			assert(gas_station_door(closed)),
			write("You have closed the gas station door."),
       	 		nl, 
			!.


/* If not near or inside gas station, cannot close it.*/
closeit(gas_station_door) :-
		not((i_am_at(gas_station); i_am_at(road))),
		write("You need to be inside or near the gas station,to close the gas station door."),
       	 	nl, 
		!.
	
/* If already closed cannot close it.*/	
closeit(gas_station_door) :-
		gas_station_door(closed),
		write("The gas station door is already closed."),
       	 	nl, 
		!.	


/* General case if player tries to close something else.*/
closeit(_) :-
		write("You can't close that."),
       	 	nl, 
		!.	


/* End of game, we ask the player to type halt so the program ends. */

finish :-
        nl,
        write("The game is over. Please enter the 'halt.' command."),
        nl.


/* Show instructions for the game. */

instructions :-
        nl,
        write("Enter commands using standard Prolog syntax."), nl,
        write("Available commands are:"), nl,
        write("go.           			  -- to start the game."), nl,
	write("goto(place).       		  -- to go to another place near your current position."), nl,
	write("open(car_door/gas_station_door).   -- to open the car door or the gas station door."), nl,
	write("closeit(car_door/gas_station_door).-- to close the car door or the gas station door."), nl,
	write("pay_with(money).  		  -- to pay the cashier."), nl,
        write("take(Object).     		  -- to pick up an object."), nl,
 	write("look.              		  -- to look around you again."), nl,
	write("holding(X)        		  -- to see your inventory."), nl,
        write("instructions.      		  -- to see this message again."), nl,
        write("halt.              		  -- to end the game and quit."), nl,
        nl.


/* Start game, show instructions and whereabouts of player. */

go :-
        instructions,
        look.


/* Description of places. Depending on the situation, a place may have more than one description.*/


describe(car) :- holding(soda),holding(newspaper),
			 write("Congratulations!!  You have acquired the soda and the newspaper."), nl,
      			 write("and won the game!"), nl,
      			 finish, !.

describe(car) :- write("You are in your car. You would love a soda and a newspaper right now."),
				 write("You see a gas station across the road."), 
                 nl.

describe(road) :- write("You are on the the road. Surprisingly, there are no cars."), 
                  nl,
       			 write("Probably because of the holidays. You can either go to your car or the gas station."),
                 nl.

describe(gas_station) :- write("This is the gas station. The cashier welcomes you with a warm smile"), nl,
						write("You can buy a variety of goods here, such as soda and the newspaper you so desire."), nl.

