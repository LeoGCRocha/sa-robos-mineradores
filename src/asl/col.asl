pos(boss,15,15).
checking_cells.
resource_needed(1).

+my_pos(X,Y) 
   :  checking_cells & not building_finished
   <- !check_for_resources.

+found(R) 
	: not resource_needed(R)
	<-
		?my_pos(X,Y);
		+resource(R,X,Y).

+!check_for_resources
   : resource_needed(R) & pos(R,X,Y) & not my_pos(X,Y)
   <- -checking_cells;
      +pos(back,X,Y);
      if (found(R)) {
         !go(R);
         !take(R,boss);
      } else {
         .print("Percebeu o esgotamento.");
         !go(boss);
      };
      !continue_mine.

+!check_for_resources
   : resource_needed(R) & pos(R,X,Y) & my_pos(X,Y) & not found(R)
   <- -pos(R,X,Y);
      .abolish(pos(R,X,Y));
      .wait(50);
      move_to(next_cell).

+!check_for_resources
   : resource_needed(R) & pos(R,X,Y) & my_pos(X,Y) & found(R)
   <- !stop_checking;
      !take(R,boss);
      !continue_mine.  

+!check_for_resources
   :  resource_needed(R) & not pos(R,X,Y) & my_pos(X,Y) & found(R)
   <- !stop_checking;
      .broadcast(tell,pos(R,X,Y));
      !take(R,boss);
      !continue_mine.   

+!check_for_resources
   :  resource_needed(R) & not found(R)
   <- .wait(50);
         move_to(next_cell).

+!stop_checking : true
   <- ?my_pos(X,Y);
      +pos(back,X,Y);
      -checking_cells.

+!take(R,B) : true
   <- 
      .wait(50);
      if (found(R)) {
         mine(R);
      };
      !go(B);
      drop(R).

+!continue_mine : true
   <- !go(back);
      -pos(back,X,Y);
      +checking_cells;
      !check_for_resources.

+!go(Position) 
   :  pos(Position,X,Y) & my_pos(X,Y)
   <- true. 

+!go(Position) : true
   <- ?pos(Position,X,Y);
      .wait(50);
      move_towards(X,Y);
      !go(Position).

@psf[atomic]
+!search_for(NewResource) : resource_needed(OldResource)
   <- +resource_needed(NewResource);    
      -resource_needed(OldResource).

@pbf[atomic]
+building_finished : true
   <- .drop_all_desires;
      !go(boss).
      