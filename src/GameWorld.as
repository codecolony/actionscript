package  
{
	import flash.display.BitmapData;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.tweens.misc.MultiVarTween;
	import net.flashpunk.tweens.misc.VarTween;
	import net.flashpunk.World;
	import net.flashpunk.utils.Input;
	import net.flashpunk.FP;
	import net.flashpunk.Sfx;
	import GV;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	/**
	 * ...
	 * @author Ragha
	 */
	public class GameWorld extends World
	{
		private var board:Entity;
		private var black1:PlayerBlack;
		private var black2:PlayerBlack;
		private var black3:PlayerBlack;
		private var white1:PlayerWhite;
		private var white2:PlayerWhite;
		private var white3:PlayerWhite;
		
		private var turn_black:PlayerBlack;
		private var turn_white:PlayerWhite;
		
		private var prev_move_object_b:PlayerBlack;
		private var prev_move_object_w:PlayerWhite;
		
		private var turn:int; //0 for black , 1 for white.
		private var blackcount:int;
		private var whitecount:int;
		private var no_move:int = -1;
		private var game_state:int = -1;  //0-init, 1-fill map, 2-player moves, 3-game end
		private var white_selected_pos:int = -1;
		private var move_cancelled:int = -1;
		private var move_rollback:int = -1;
		
		//private var turn_text:Text;  //text for display
		//private var turn_text_image:Image;  //text for display
		//private var turn_text_entity:Image;  //text for display
		//private var reset:Text;
		private var reset_image:Image;
		private var reset_entity:Entity;
		//private var instruct:Text;
		private var rules_image:Image;
		private var rules_entity:Entity;
		private var win_image:Image;
		private var win_entity:Entity;
		private var lose_image:Image;
		private var lose_entity:Entity;
		private var invalid_image:Image;
		private var invalid_entity:Entity;
		private var app_image:Image;
		private var app_entity:Entity;
		private var you_image:Image;
		private var you_entity:Entity;
		
		private var move:int = -1;
		private var insert:int = -1;
		private var insertcount:int = 0;
		private var prev_move_index:int = -1;
		private var game_finished:int = 0;
		private var winning_solution:int  = -1;
		
		private var myTimer:Timer;
		
		private var boardmap:Array = new Array();  //occupancy map
		private var positions:Array = new Array(); //player locations
		private var objects:Array = new Array();  //actual ojects stored
		
		private var error:Sfx = new Sfx(GV.ERROR_SOUND);
		private var success:Sfx = new Sfx(GV.LOCK_PLACE);
		private var win:Sfx = new Sfx(GV.WIN_SOUND);
		private var lose:Sfx = new Sfx(GV.LOSE_SOUND);
		
		[Embed(source = "assets/board2.jpg")] private const BOARD:Class;
		[Embed(source = "assets/invalidmove4.png")] private const INVALID_MOVE:Class;
		[Embed(source = "assets/reset4.png")] private const RESET:Class;
		[Embed(source = "assets/rules4.png")]private const RULES:Class;
		[Embed(source = "assets/youlose4.png")]private const YOU_LOSE:Class;
		[Embed(source = "assets/youwin4.png")]private const YOU_WIN:Class;
		[Embed(source = "assets/appplays4.png")] private const APP_PLAYS:Class;
		[Embed(source = "assets/youplay8.png")] private const YOU_PLAY:Class;
		
		public function GameWorld() 
		{
			trace("In game world");
			
			//turn_text = new Text("ragha", 470, 70);
			//turn_text.color = 0;
			//turn_text.size = 30;
			boardmap[0]  = new Array();
			boardmap[0][0] = 0;
			boardmap[0][1] = 0;
			boardmap[0][2] = 0;
			
			boardmap[1]  = new Array();
			boardmap[1][0] = 0;
			boardmap[1][1] = 0;
			boardmap[1][2] = 0;
			
			boardmap[2]  = new Array();
			boardmap[2][0] = 0;
			boardmap[2][1] = 0;
			boardmap[2][2] = 0;
			
			positions[0] = 2;
			positions[1] = 2;
			positions[2] = 2;
			positions[3] = 2;
			positions[4] = 2;
			positions[5] = 2;
			positions[6] = 2;
			positions[7] = 2;
			positions[8] = 2;
			
			objects[0] = new Array();
		}
		
		override public function begin( ):void {
			var image:Image = new Image(BOARD);
			board = new Entity(0, 0, image);
			add(board);
						
			black1 = new PlayerBlack();
			black2 = new PlayerBlack();
			black3 = new PlayerBlack();
			
			white1 = new PlayerWhite();
			white2 = new PlayerWhite();
			white3 = new PlayerWhite();
					
			add(black1);
			turn_black =  black1;
			turn = 0; //black plays first!
			//turn_text.text  = "You play!";
			//you_entity.visible = true;
			
			//addGraphic(turn_text);
			
			blackcount = 0; //black player playing first time.
			whitecount = 0; //white yet to play!
			game_state = 0;
			
			loadTexts();
			
			super.begin( );
		}
		
		private function hideAllStatusTexts():void {
			you_entity.visible = false;
			app_entity.visible = false;
			win_entity.visible = false;
			lose_entity.visible = false;
			invalid_entity.visible = false;
		}
		
		private function loadTexts():void {
			
			//hanlde text images. should be moved to a different method
			rules_image = new Image(RULES);
			rules_image.scale = 0.6;
			rules_entity = new Entity(470, 240, rules_image);
			add(rules_entity);
			//rules_entity.visible = false;
			
			reset_image = new Image(RESET);
			reset_image.scale = 0.6;
			reset_entity = new Entity(470, 170, reset_image);
			add(reset_entity);
			//reset_entity.visible = false;
			
			
			win_image = new Image(YOU_WIN);
			win_image.scale = 0.6;
			win_entity = new Entity(470, 70, win_image);
			add(win_entity);
			win_entity.visible = false;
			
			lose_image = new Image(YOU_LOSE);
			lose_image.scale = 0.6;
			lose_entity = new Entity(470, 70, lose_image);
			add(lose_entity);
			lose_entity.visible = false;
			
			invalid_image = new Image(INVALID_MOVE);
			invalid_image.scale = 0.6;
			invalid_entity = new Entity(470, 70, invalid_image);
			add(invalid_entity);
			invalid_entity.visible = false;
			
			you_image = new Image(YOU_PLAY);
			you_image.scale = 0.6;
			you_entity = new Entity(470, 70, you_image);
			add(you_entity);
			//you_entity.visible = false;
			
			app_image = new Image(APP_PLAYS);
			app_image.scale = 0.6;
			app_entity = new Entity(470, 70, app_image);
			add(app_entity);
			app_entity.visible = false;
		}
		
		override public function update():void {
			
			handleMenu();
			
			if (game_finished == 1) 
			{
				return;
			}
			
			if (turn == 0) //black playing first.
			{
				if (turn_black!= null) 
				{
					if(move_cancelled != 1 ){
					turn_black.x = Input.mouseX-30;
					turn_black.y = Input.mouseY - 30;
					}
					else {
						//playerMoves(Input.mouseX, Input.mouseY, turn);
						if (move_rollback == 1) {
							//move_cancelled = 0;
						}
					}
				
					
				}
				if (Input.mousePressed && turn_black!=null) 
				{
					if (checkValidMoveForInsert(Input.mouseX, Input.mouseY, turn, turn_black, null) == 1) {
						
						//move_rollback = 1;
						//turn_black.x = Input.mouseX-30;
						//turn_black.y = Input.mouseY - 30;
						
						if (move_rollback == 1) 
						{
							move_cancelled = 0;
						}
						
						if (move_cancelled != 1) {
							no_move = 0;  //valid move
							turn_black = null;
							blackcount++;
							if (evaluateWinner(turn,positions) == 1)
							{	
								//turn_text.text = "You Win!";
								hideAllStatusTexts();
								win_entity.visible = true;
								handleEnd(1);
							}
							else{
								//turn_text.text = "App plays!";
								hideAllStatusTexts();
								app_entity.visible = true;
								success.play();
							}
							turn = 1; //give chance to white now.
						}
						else {
							//move_cancelled = 0;
							move_rollback = 1;
							turn_black = null;
							nextTurn();
							return;
							//no_move = 1;
						}
					}
					else {
						//trace("Invalid spot!");
						//turn_text.text  = "Try again!";
						hideAllStatusTexts();
						invalid_entity.visible = true;
						error.play();
						no_move = 1;
						//turn_black = null;
						//return;
						//move_cancelled = 1;
						//sounds alarm.
					}
				}
			}
			else { //white is playing
				if (turn_white!= null) 
				{
					//turn_white.x = Input.mouseX-30;
					//turn_white.y = Input.mouseY-30;
					//sleep_ms(8000);
				}
				if (turn_white!=null) 
				{
					//playWhite();
					if (checkValidMoveForInsert(Input.mouseX, Input.mouseY, turn, null, turn_white) == 1) {
						no_move = 0;
					turn_white = null;
					whitecount++;
						if (evaluateWinner(turn,positions) == 1) 
						{
							//turn_text.text = "You lose!";
							hideAllStatusTexts();
							lose_entity.visible = true;
							handleEnd(0);
						}
						else{
							//turn_text.text  = "You play!";
							hideAllStatusTexts();
							you_entity.visible = true;
							success.play();
							}
							turn = 0; // blacks turn to play.
						}
					else {
						//trace("Invalid spot!");
						//turn_text.text  = "Try again!"; 
						hideAllStatusTexts();
						invalid_entity.visible = true;
						error.play();
						no_move = 1;
						//sound alarm.
					}
					}
				}
				
				//Input.update();
			//if (whitecount >= 3 && Input.mousePressed && no_move==0) 
			if (whitecount >= 3  && no_move==0) 
			{
				game_state = 2;
				//if (move == -1) { move = 1; return; }
				//if(move==1)
				{playerMoves(Input.mouseX,Input.mouseY, turn);}
			}
			else {
				nextTurn();
			}
			
			super.update();
		}
		
		//don't forget to move it to game utils.
		private function sleep_ms(ms:int):void {
			myTimer = new Timer(ms, 1); // 1 second delay
			myTimer.addEventListener(TimerEvent.TIMER, runOnce);
			myTimer.start();
		}
		
		private function runOnce(event:TimerEvent):void {
			myTimer.stop();
		}
		
		private function moveWhiteToDestination(white:PlayerWhite, x:int, y:int):void {
			//take care to adjust the game variables
			var tweenInfo:Object = new Object();
			tweenInfo.x = x;
			tweenInfo.y = y;
			
			//App play display
			hideAllStatusTexts();
			app_entity.visible = true;
			//sleep_ms(500);
			
			var moving:MultiVarTween = new MultiVarTween();
				moving.tween(white,tweenInfo,0.5);
				addTween(moving,true);
			
		}
		
		private function checkAdjacentFree(indx:int):int {  //returns the free position
			
			var ret:int = -1;
			if (indx == 0) 
			{
				if (board[0][1] == 0) ret =  1;
				else if (board[1][1] == 0) ret = 4;
				else if (board[1][0] == 0) ret = 3;
			}
			
			return ret;
		}

		
		private function getBestWhiteMarble():int {
			
			var pos:int;
			var tmp:int = -1;
			
			winning_solution = -1;
			
			if (positions[0]==1) 
			{
				pos = getWinningMove(0);
				if (pos != -1) 
				{
					return pos;
				}
				
			}
			if (positions[1]==1) 
			{
				winning_solution = -1;
				
				pos = getWinningMove(1);
				if (pos != -1) 
				{
					return pos;
				}
			}
			if (positions[2]==1) 
			{
				winning_solution = -1;
				pos = getWinningMove(2);
				if (pos != -1) 
				{
					return pos;
				}
			}
			if (positions[3]==1) 
			{
				winning_solution = -1;
				pos = getWinningMove(3);
				if (pos != -1) 
				{
					return pos;
				}
			}
			if (positions[4]==1) 
			{
				winning_solution = -1;
				pos = getWinningMove(4);
				if (pos != -1) 
				{
					return pos;
				}
			}
			if (positions[5]==1) 
			{
				winning_solution = -1;
				pos = getWinningMove(5);
				if (pos != -1) 
				{
					return pos;
				}
			}
			if (positions[6]==1) 
			{
				winning_solution = -1;
				pos = getWinningMove(6);
				if (pos != -1) 
				{
					return pos;
				}
			}
			if (positions[7]==1) 
			{
				winning_solution = -1;
				pos = getWinningMove(7);
				if (pos != -1) 
				{
					return pos;
				}
			}
			if (positions[8]==1) 
			{
				winning_solution = -1;
				pos = getWinningMove(8);
				if (pos != -1) 
				{
					return pos;
				}
			}
			
			//stop opponent from winning.
			
			return pos;
		}
		
		private function nextTurn():void {
			
			if (move_cancelled==1 && move_rollback ==1) 
			{
				move_cancelled = 0;
				move_rollback = 0;
				return;
			}
			if (turn == 0) 
			{
				if (blackcount==1) 
				{
					turn_black = black2;
					this.add(black2);
				}
				else if (blackcount == 2) {
					turn_black = black3;
					this.add(black3);
				}
				
			}
			if (turn == 1) 
			{
				if (whitecount==0) 
				{
					turn_white = white1;
					this.add(white1);
				}
				else if (whitecount==1) 
				{
					turn_white = white2;
					this.add(white2);
				}
				else if (whitecount==2) 
				{
					turn_white = white3;
					this.add(white3);
				}
			}
		}
		
		private function playerMoves(x:int, y:int, turn:int):void {
			
			if (turn == 1) 
			{
				sleep_ms(1000);
			}
			
			if (!Input.mousePressed && turn == 0) {
				return;
			}
			if (insert == -1) 
			{
					insert = 0;
					move = 1;
			}
			if (checkMoveAllowed(x, y, turn) == 0 && insert!= 1){
				error.play();
			}
			else {
				if (move_cancelled == 1) 
				{
					move_rollback = 1;
				}
				
				insert = 1;
				move = 0;
			}
			
		}
		
		private function getRandomFreeSpot():int {
			var ret:int = -1;
			var x:int = -1;
			var y:int = -1;
			
			if (boardmap[1][1]==0) //centre free! grab it!
			{
				return 4;
			}
			
			while (true)
			{
				x = FP.rand(3);
				y = FP.rand(3);
				
				if (boardmap[x][y] == 0) {
					if (x == 0 && y == 0) ret = 0;
					else if (x == 0 && y == 1) ret = 1;
					else if (x == 0 && y == 2) ret = 2;
					else if (x == 1 && y == 0) ret = 3;
					else if (x == 1 && y == 1) ret = 4;
					else if (x == 1 && y == 2) ret = 5;
					else if (x == 2 && y == 0) ret = 6;
					else if (x == 2 && y == 1) ret = 7;
					else if (x == 2 && y == 2) ret = 8;
					break;
				}
			}
			
			return ret;
		}
		private function checkValidMoveForInsert(x:int, y:int, player:int, black:PlayerBlack, white:PlayerWhite ):int { //insert
			
			if (game_finished == 1) 
			{
				handleMenu();
				return 2;
			}
			
			/*if (game_state == 2 && hasMoves(prev_move_index) == 0) {
						return 0;
					}*/
					
			var randFreeSpot:int = -1;
			if (player == 1 && game_state == 1) {  //game in initial marble distribution state
				randFreeSpot = getRandomFreeSpot();
				x = -1;
				y = -1;
			}
			else if (player == 1 && game_state == 2) { //game in player marbles moving state
				randFreeSpot = getWinningMove(white_selected_pos);
				if (randFreeSpot == -1) 
				{
					randFreeSpot = getRandomValidMove(white_selected_pos);
				}
				
				x = -1;
				y = -1;
			}

			//(33,35,95,95)   (194,34,290,84)  (375,34,442,96)
			
			var retval:int = 0;
			if ((x>33 && x<95) && (y>35 && y<95)|| randFreeSpot == 0) //

			{
				if (prev_move_index == 0) { move_cancelled = 1; } //same position playng is not alowed.
				else if (game_state == 2 && hasMoves(prev_move_index,0) == 0) {
						return 0;
				}
				if (boardmap[0][0] == 0 || move_cancelled == 1) 
				{
					retval = 1;
					boardmap[0][0] = 1;
					positions[0] = player;
					if (black==null) 
					{
						//white.x = 35;
						//white.y = 36;
						moveWhiteToDestination(white, 35, 36);
						objects[0] = white;
					}
					else {
						objects[0] = black;
					}
					
				}
			}
			else if ((x>194 && x<290) && (y>34 && y<95)|| randFreeSpot == 1)
			{
				if (prev_move_index == 1) { move_cancelled = 1; }
				else if (game_state == 2 && hasMoves(prev_move_index,1) == 0) {
						return 0;
				}
				if (boardmap[0][1] == 0 || move_cancelled == 1) 
				{
					retval = 1;
					boardmap[0][1] = 1;
					positions[1] = player;
					if (black==null) 
					{
						//white.x = 214;
						//white.y = 34;
						moveWhiteToDestination(white, 214, 34);
						objects[1] = white;
					}
					else {
						objects[1] = black;
					}
					
				}
			}
			else if ((x>375 && x<442) && (y>34 && y<95)|| randFreeSpot == 2)
			{
				if (prev_move_index == 2) { move_cancelled = 1; }
				else if (game_state == 2 && hasMoves(prev_move_index,2) == 0) {
						return 0;
				}
				if (boardmap[0][2] == 0 || move_cancelled == 1) 
				{
					retval = 1;
					boardmap[0][2] = 1;
					positions[2] = player;
					if (black==null) 
					{
						//white.x = 388;
						//white.y = 36;
						moveWhiteToDestination(white, 388, 36);
						objects[2] = white;
					}
					else {
						objects[2] = black;
					}
					
				}
			}
			//(31,182,84,276) (187,180,287,275) (395,178,445,277)
			
			
			else if ((x>31 && x<84) && (y>182 && y<276)|| randFreeSpot == 3)
			{
				if (prev_move_index == 3) { move_cancelled = 1; }
				else if (game_state == 2 && hasMoves(prev_move_index,3) == 0) {
						return 0;
				}
				if (boardmap[1][0] == 0 || move_cancelled == 1) 
				{
					retval = 1;
					boardmap[1][0] = 1;
					positions[3] = player;
					if (black==null) 
					{
						//white.x = 31;
						//white.y = 202;
						moveWhiteToDestination(white, 31, 202);
						objects[3] = white;
					}
					else {
						objects[3] = black;
					}
					
				}
			}
			else if ((x>187 && x<287) && (y>180 && y<275)|| randFreeSpot == 4)
			{
				if (prev_move_index == 4) { move_cancelled = 1; }
				else if (game_state == 2 && hasMoves(prev_move_index,4) == 0) {
						return 0;
				}
				if (boardmap[1][1] == 0  || move_cancelled == 1) 
				{
					retval = 1;
					boardmap[1][1] = 1;
					positions[4] = player;
					if (black==null) 
					{
						//white.x = 210;
						//white.y = 200;
						moveWhiteToDestination(white, 210, 200);
						objects[4] = white;
					}
					else {
						objects[4] = black;
					}
					
				}
			}
			else if ((x>395 && x<445) && (y>178 && y<277)|| randFreeSpot == 5)
			{
				if (prev_move_index == 5) { move_cancelled = 1; }
				else if (game_state == 2 && hasMoves(prev_move_index,5) == 0) {
						return 0;
				}
				if (boardmap[1][2] == 0 || move_cancelled == 1) 
				{
					retval = 1;
					boardmap[1][2] = 1;
					positions[5] = player;
					if (black==null) 
					{
						//white.x = 405;
						//white.y = 212;
						moveWhiteToDestination(white, 405, 212);
						objects[5] = white;
					}
					else {
						objects[5] = black;
					}
					
				}
			}
			
			//(26,362,97,435) (189,385,287,432) (380,364,455,433)
			else if ((x>26 && x<97) && (y>362 && y<435)|| randFreeSpot == 6)
			{
				if (prev_move_index == 6) { move_cancelled = 1; }
				else if (game_state == 2 && hasMoves(prev_move_index,6) == 0) {
						return 0;
				}
				if (boardmap[2][0] == 0 || move_cancelled == 1) 
				{
					retval = 1;
					boardmap[2][0] = 1;
					positions[6] = player;
					if (black==null) 
					{
						//white.x = 26;
						//white.y = 374;
						moveWhiteToDestination(white, 26, 374);
						objects[6] = white;
					}
					else {
						objects[6] = black;
					}
					
				}
			}
			else if ((x>189 && x<287) && (y>385 && y<432)|| randFreeSpot == 7)
			{
				if (prev_move_index == 7) { move_cancelled = 1; }
				else if (game_state == 2 && hasMoves(prev_move_index,7) == 0) {
						return 0;
				}
				if (boardmap[2][1] == 0 || move_cancelled == 1) 
				{
					retval = 1;
					boardmap[2][1] = 1;
					positions[7] = player;
					if (black==null) 
					{
						//white.x = 200;
						//white.y = 385;
						moveWhiteToDestination(white, 200, 385);
						objects[7] = white;
					}
					else {
						objects[7] = black;
					}
					
				}
			}
			else if ((x>380 && x<455) && (y>364 && y<433)|| randFreeSpot == 8)
			{
				if (prev_move_index == 8) { move_cancelled = 1; }
				else if (game_state == 2 && hasMoves(prev_move_index,8) == 0) {
						return 0;
				}
				if (boardmap[2][2] == 0 || move_cancelled == 1) 
				{
					retval = 1;
					boardmap[2][2] = 1;
					positions[8] = player;
					if (black==null) 
					{
						//white.x = 400;
						//white.y = 384;
						moveWhiteToDestination(white, 400, 384);
						objects[8] = white;
					}
					else {
						objects[8] = black;
					}
					
				}
			}
			insertcount++;
			if (insertcount <6) 
			{
				game_state = 1;
			}
			if( retval == 1 && prev_move_index!=-1 && move_cancelled != 1){
					objects[prev_move_index] = null;
					move_cancelled = 0;
			}
			else if (move_cancelled==1) 
			{
				objects[prev_move_index] = black;
			}
			if (move != -1 && insertcount >=6 && retval == 1 ) 
			{
				
					insert = 0;
					move = 1;
				
				
			}
			
			
			return retval;
		}
		
		private function evaluateWinner(player:int, positions:Array):int {
			
			var retval:int = 0;
			
			if (positions[0] == player && positions[1] == player && positions[2] == player) {
				retval = 1;
			}
			else if (positions[3] == player && positions[4] == player && positions[5] == player) 
			{
				retval = 1;
			}
			else if (positions[6] == player && positions[7] == player && positions[8] == player) 
			{
				retval = 1;
			}
			else if (positions[0] == player && positions[3] == player && positions[6] == player) 
			{
				retval = 1;
			}
			else if (positions[1] == player && positions[4] == player && positions[7] == player) 
			{
				retval = 1;
			}
			else if (positions[2] == player && positions[5] == player && positions[8] == player) 
			{
				retval = 1;
			}
			else if (positions[0] == player && positions[4] == player && positions[8] == player) 
			{
				retval = 1;
			}
			else if (positions[2] == player && positions[4] == player && positions[6] == player) 
			{
				retval = 1;
			}
			
			return retval;
		}
		
		private function handleEnd(won:int):void {
			if (won == 1) 
			{
				win.play();
			}
			else if (won == 0) 
			{
				lose.play();
			}
			
			if (insertcount == 5) 
			{
				//this.remove(white3.);
				white3.visible = false;
			}
			else if(insertcount == 6) {
				//this.remove(black3);
				black3.visible = false;
			}
			//this.active = false;
			
			game_finished = 1;
			
		
			showMenu();
			
		}
		
		private function checkMoveAllowed(x:int, y:int, turn:int):int { //move
			//(33,35,95,95)   (194,34,290,84)  (375,34,442,96)
			
			if (game_finished == 1) 
			{
				handleMenu();
				return 2;
			}
			
			if (move == -1) 
			{
				return 1;
			}
			
			//if (move_cancelled == 1) 
			//{
			//	return 1;
			//}
			
			var randFreeSpot:int = -1;
			
			if (turn == 1 && game_state == 1) {  //game in initial marble distribution state
				randFreeSpot = getRandomFreeSpot();
				x = -1;
				y = -1;
			}
			else if (turn == 1 && game_state == 2) { //game in player marbles moving state
				randFreeSpot  = getWinningMove();
				if(randFreeSpot == -1)
					randFreeSpot  = getBestWhiteMarble();
					
				white_selected_pos = randFreeSpot;
				x = -1;
				y = -1;
			}
			
			var retval:int = 0;
			var index:int = -1;
			
			if ((x>33 && x<95) && (y>35 && y<95) || randFreeSpot == 0) //
			{
				if (boardmap[0][0] == 1) 
				{
					if (positions[0]==turn) 
					{
						retval = 1;
						index = 0;
						if (move_cancelled != 1) 
						{
							boardmap[0][0] = 0;
							positions[0] = 2;
						}
						
					}
					
				}
			}
			else if ((x>194 && x<290) && (y>34 && y<95)|| randFreeSpot == 1)
			{
				if (boardmap[0][1] == 1) 
				{
					
					if (positions[1]==turn) 
					{
						retval = 1;
						index = 1;
						if (move_cancelled != 1) 
						{
						boardmap[0][1] = 0;
						positions[1] = 2;
						}
					}
					
					
				}
			}
			else if ((x>375 && x<442) && (y>34 && y<95)|| randFreeSpot == 2)
			{
				if (boardmap[0][2] == 1) 
				{
					if (positions[2]==turn) 
					{
						retval = 1;
						index = 2;
						if (move_cancelled != 1) 
						{
						boardmap[0][2] = 0;
						positions[2] = 2;
						}
					}
					
					
				}
			}
			//(31,182,84,276) (187,180,287,275) (395,178,445,277)
			
			
			else if ((x>31 && x<84) && (y>182 && y<276)|| randFreeSpot == 3)
			{
				if (boardmap[1][0] == 1) 
				{
					if (positions[3]==turn) 
					{
						retval = 1;
						index = 3;
						if (move_cancelled != 1) 
						{
						boardmap[1][0] = 0;
						positions[3] = 2;
						}
					}
					
					
				}
			}
			else if ((x>187 && x<287) && (y>180 && y<275)|| randFreeSpot == 4)
			{
				if (boardmap[1][1] == 1) 
				{
					if (positions[4]==turn) 
					{
						retval = 1;
						index = 4;
						if (move_cancelled != 1) 
						{
						boardmap[1][1] = 0;
						positions[4] = 2;
						}
					}
					
					
				}
			}
			else if ((x>395 && x<445) && (y>178 && y<277)|| randFreeSpot == 5)
			{
				if (boardmap[1][2] == 1) 
				{
					if (positions[5]==turn) 
					{
						retval = 1;
						index = 5;
						if (move_cancelled != 1) 
						{
						boardmap[1][2] = 0;
						positions[5] = 2;
						}
					}
					
					
				}
			}
			
			//(26,362,97,435) (189,385,287,432) (380,364,455,433)
			else if ((x>26 && x<97) && (y>362 && y<435)|| randFreeSpot == 6)
			{
				if (boardmap[2][0] == 1) 
				{
					if (positions[6]==turn) 
					{
						retval = 1;
						index = 6;
						if (move_cancelled != 1) 
						{
						boardmap[2][0] = 0;
						positions[6] = 2;
						}
					}
					
					
				}
			}
			else if ((x>189 && x<287) && (y>385 && y<432)|| randFreeSpot == 7)
			{
				if (boardmap[2][1] == 1) 
				{
					if (positions[7]==turn) 
					{
						retval = 1;
						index = 7;
						if (move_cancelled != 1) 
						{
						boardmap[2][1] = 0;
						positions[7] = 2;
						}
					}
					
					
				}
			}
			else if ((x>380 && x<455) && (y>364 && y<433)|| randFreeSpot == 8)
			{
				if (boardmap[2][2] == 1) 
				{
					if (positions[8]==turn) 
					{
						retval = 1;
						index = 8;
						if (move_cancelled != 1) 
						{
						boardmap[2][2] = 0;
						positions[8] = 2;
						}
					}
					
					
				}
			}
			
			if (retval == 1) 
			{
				if (turn == 0) 
				{
					turn_black = objects[index];
					prev_move_object_b = turn_black;
				}
				else {
					turn_white = objects[index];
					prev_move_object_w = turn_white;
				}
				prev_move_index = index;
			}
			//objects[index] = null;
			insert = 1;
			move = 0;
			return retval;
		}
		
		private function showMenu():void {
			
			/*trace("In menu");
			reset = new Text("Reset", 470, 170);
			reset.color = 0;
			reset.size = 30;
			reset.text = "Reset";
			reset.smooth;
			addGraphic(reset);
			instruct = new Text("Rules", 470, 240);
			instruct.color = 0;
			instruct.size = 30;
			instruct.text = "Rules";
			instruct.smooth;
			addGraphic(instruct);*/
			
			/*if (Input.mouseX > 470 &&  Input.mouseX < 560 && Input.mouseY > 170 && Input.mouseY < 200) {
					reset.scaleY = 1.1;
					reset.update();
			}
			else {
				//reset.scale = 0.9;
				//reset.update();
			}*/
			
			
			
		}
		
		private function handleMenu():void {
			if (Input.mousePressed) 
			{
				if (Input.mouseX > 470 &&  Input.mouseX < 560 && Input.mouseY > 170 && Input.mouseY < 200) {
					FP.world = new GameWorld();
				}
				
				else if (Input.mouseX > 470 &&  Input.mouseX < 560 && Input.mouseY > 240 && Input.mouseY < 270) {
					//game rules here.
				}
			}
		}
		
		private function hasMoves(pos:int, dest:int):int {
			
			var ret:int = 0;
			
			if (pos == 0) 
			{
				//00 01 02
				//10 11 12
				//20 21 22

				//0  1  2
				//3  4  5
				//6  7  8
				if (boardmap[0][1] == 0 || boardmap[1][1] ==0 || boardmap[1][0]==0) 
				{
					if (dest == 1 || dest == 4 || dest == 3) 
					{
						ret = 1;  //checked.
					}
				}
			}
			else if (pos == 1)
			{
				if (boardmap[0][0] == 0 || boardmap[1][1] ==0 || boardmap[0][2]==0) 
				{
					if (dest == 0 || dest == 4 || dest == 2) 
					{
						ret = 1;  //checked.
					}
				}
			}
			else if (pos == 2)
			{
				if (boardmap[0][1] == 0 || boardmap[1][1] ==0 || boardmap[1][2]==0) 
				{
					if (dest == 1 || dest == 4 || dest == 5) 
					{
						ret = 1;  //checked.
					}
				}
			}
			else if (pos == 3)
			{
				if (boardmap[0][0] == 0 || boardmap[1][1] ==0 || boardmap[2][0]==0) 
				{
					if (dest == 0 || dest == 4 || dest == 6) 
					{
						ret = 1;  //checked.
					}
				}
			}
			else if (pos == 4)
			{
				//if (boardmap[0][1] == 0 || boardmap[1][1] ==0 || boardmap[1][0]==0) 
				//{
					ret = 1; //checked.
				//}
			}
			else if (pos == 5)
			{
				if (boardmap[0][2] == 0 || boardmap[1][1] ==0 || boardmap[2][2]==0) 
				{
					if (dest == 2 || dest == 4 || dest == 8) 
					{
						ret = 1;  //checked.
					}
				}
			}
			else if (pos == 6)
			{
				if (boardmap[2][1] == 0 || boardmap[1][1] ==0 || boardmap[1][0]==0) 
				{
					if (dest == 7 || dest == 4 || dest == 3) 
					{
						ret = 1;  //checked.
					}
				}
			}
			else if (pos == 7)
			{
				if (boardmap[2][2] == 0 || boardmap[1][1] ==0 || boardmap[2][0]==0) 
				{
					if (dest == 8 || dest == 4 || dest == 6) 
					{
						ret = 1;  //checked.
					}
				}
			}
			else if (pos == 8)
			{
				if (boardmap[2][1] == 0 || boardmap[1][1] ==0 || boardmap[1][2]==0) 
				{
					if (dest == 7 || dest == 4 || dest == 5) 
					{
						ret = 1;  //checked.
					}
				}
			}
			
			return ret;
		}
		
		private function getRandomValidMove(pos:int):int {
			var ret:int = -1;
			var winret:int = -1; //winning return
			var temp:int = 0;
			var newpos:Array = positions.slice();
			newpos[pos] = 1;
			
			if (pos == 0) 
			{
				//check for winning first
				if (boardmap[1][1] == 0) 
				{
					//ret = 4;
					newpos[4] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						ret = 4;  //checked.
					}
					
				}
				else if (boardmap[0][1] == 0) {
					//ret = 1;
					newpos[1] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						ret = 1;  //checked.
					}
				}
				else if (boardmap[1][0]==0)  
				{
					//ret = 3;
					newpos[3] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						ret = 3;  //checked.
					}
				}
				
				//check if I need to stop opponent winning.
				if (ret == 0) 
				{
					ret = 4;  //just return last one now.
				}
			}
			else if (pos == 1)
			{
				if (boardmap[1][1] == 0) 
				{
					ret = 4;  //checked.
					newpos[4] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 4;  //checked.
					}
				}
				else if (boardmap[0][0] == 0 && winret == -1) {
					ret = 0;
					newpos[0] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 0;  //checked.
					}
				}
				else if (boardmap[0][2]==0 && winret == -1) 
				{
					ret = 2;
					newpos[2] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 2;  //checked.
					}
				}
				
			}
			else if (pos == 2)
			{
				if (boardmap[1][1] == 0) 
				{
					ret = 4;  //checked.
					newpos[4] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 4;  //checked.
					}
				}
				else if (boardmap[0][1] == 0 && winret == -1) {
					ret = 1;
					newpos[1] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 1;  //checked.
					}
				}
				else if (boardmap[1][2]==0 && winret == -1)  
				{
					ret = 5;
					newpos[5] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 5;  //checked.
					}
				}
				
			}
			else if (pos == 3)
			{
				if (boardmap[1][1] == 0) 
				{
					ret = 4;  //checked.
					newpos[4] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 4;  //checked.
					}
				}
				else if (boardmap[0][0] == 0 && winret == -1) {
					ret = 0;
					newpos[0] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 0;  //checked.
					}
				}
				else if (boardmap[2][0]==0 && winret == -1)  
				{
					ret = 7;
					newpos[7] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 7;  //checked.
					}
				}
			}
			else if (pos == 4)
			{
				//need some awesome logic here. to be revisited
				if (boardmap[0][0] == 0) 
				{
					ret = 0;  //checked.
					newpos[0] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 0;  //checked.
					}
				}
				else if (boardmap[0][1] == 0 && winret == -1) {
					ret = 1;
					newpos[1] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 1;  //checked.
					}
				}
				else if (boardmap[0][2] == 0 && winret == -1) {
					ret = 2;
					newpos[2] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 2;  //checked.
					}
				}
				else if (boardmap[1][0]==0 && winret == -1)  
				{
					ret = 3;
					newpos[3] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 3;  //checked.
					}
				}
				else if (boardmap[1][2] == 0 && winret == -1) {
					ret = 5;
					newpos[5] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 5;  //checked.
					}
				}
				else if (boardmap[2][0] == 0 && winret == -1) {
					ret = 6;
					newpos[6] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 6;  //checked.
					}
				}
				else if (boardmap[2][1] == 0 && winret == -1) {
					ret = 7;
					newpos[7] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 7;  //checked.
					}
				}
				else if (boardmap[2][2] == 0 && winret == -1) {
					ret = 8;
					newpos[8] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 8;  //checked.
					}
				}
			}
			else if (pos == 5)
			{
				
				if (boardmap[1][1] == 0) 
				{
					ret = 4;  //checked.
					newpos[4] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 4;  //checked.
					}
				}
				else if (boardmap[0][2] == 0 && winret == -1) {
					ret = 2;
					newpos[2] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 2;  //checked.
					}
				}
				else if (boardmap[2][2]==0 && winret == -1)  
				{
					ret = 8;
					newpos[8] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 8;  //checked.
					}
				}
			}
			else if (pos == 6)
			{
				
				if (boardmap[1][1] == 0) 
				{
					ret = 4;  //checked.
					newpos[4] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 4;  //checked.
					}
				}
				else if (boardmap[2][1] == 0 && winret == -1) {
					ret = 7;
					newpos[7] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 7;  //checked.
					}
				}
				else if (boardmap[1][0]==0 && winret == -1)  
				{
					ret = 3;
					newpos[3] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 3;  //checked.
					}
				}
			}
			else if (pos == 7)
			{
				
				if (boardmap[1][1] == 0) 
				{
					ret = 4;  //checked.
					newpos[4] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 4;  //checked.
					}
				}
				else if (boardmap[2][2] == 0 && winret == -1) {
					ret = 8;
					newpos[8] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 8;  //checked.
					}
				}
				else if (boardmap[2][0]==0 && winret == -1)  
				{
					ret = 6;
					newpos[6] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 6;  //checked.
					}
				}
			}
			else if (pos == 8)
			{
				/*if (boardmap[2][1] == 0)// || boardmap[1][1] ==0 || boardmap[1][2]==0) 
				{
					//ret = 1;  //checked.
					newpos[1] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						ret = 1;  //checked.
					}
				}*/
				if (boardmap[1][1] == 0) 
				{
					ret = 4;  //checked.
					newpos[4] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 4;  //checked.
					}
				}
				else if (boardmap[2][1] == 0 && winret == -1) {
					ret = 7;
					newpos[7] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 7;  //checked.
					}
				}
				else if (boardmap[1][2]==0 && winret == -1)  
				{
					ret = 5;
					newpos[5] = 1;
					newpos[pos] = 2;
					if(evaluateWinner(1, newpos) == 1) {
						winret = 5;  //checked.
					}
				}
			}
			
			if (winret!= -1) 
			{
				ret = winret;
				winning_solution = 1;
			}
			
			return ret;
		}
		
		private function getWinningMove(pos:int = -1 ):int { //-1 means check all positions
			var ret:int = -1;
			var newpos:Array = positions.slice();
			var player:int;
			var middle:int = -1;
			
			if (pos==-1) 
			{
				player = 1;
			}
			else {
				player = 2;
				
			}
			//newpos[pos] = 1;  //white in new position
				
			if ((pos == 0 || pos == -1) && positions[0]==player) 
			{
				//newpos[0] = 1;  //white in new position
				//check for winning first
				if (pos != -1) 
				{
					positions[pos] = 1; //revert back at the end.
				}
				if (boardmap[1][1] == 0) 
				{
					
					if(pos != -1)
						{ret = 4;  middle = 4; } //checked.
					else 
						ret = 0;
					newpos[4] = 1;
					newpos[0] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 0;  //checked.
					}
					
				}
				newpos = positions.slice();
				//newpos[0] = 1;
				if (boardmap[0][1] == 0) {
					
					if(pos != -1)
						ret = 1;  //checked.
					else 
						ret = 0;
					newpos[1] = 1;
					newpos[0] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 0;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[0] = 1;
				if (boardmap[1][0]==0)  
				{
					
					if(pos != -1)
						ret = 3;  //checked.
					else 
						ret = 0;
					newpos[3] = 1;
					newpos[0] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 0;  //checked.
					}
				}
			}
			
			if ((pos == 1 || pos == -1 ) && positions[1]==player)
			{
				if (pos != -1) 
				{
					positions[pos] = 1; //revert back at the end.
				}
				newpos = positions.slice();
				//newpos[1] = 1;
				if (boardmap[1][1] == 0) 
				{
					
					if(pos != -1)
						{ret = 4; middle = 4;} //checked.
					else 
						ret = 1;
					newpos[4] = 1;
					newpos[0] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 1;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[1] = 1;
				if (boardmap[0][0] == 0) {
					
					if(pos != -1)
						ret = 0;  //checked.
					else 
						ret = 1;
					newpos[0] = 1;
					newpos[0] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 1;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[1] = 1;
				if (boardmap[0][2]==0) 
				{
					
					if(pos != -1)
						ret = 2;  //checked.
					else 
						ret = 1;
					newpos[2] = 1;
					newpos[0] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 1;  //checked.
					}
				}
				
			}
			
			if ((pos == 2 || pos == -1) && positions[2]==player)
			{
				if (pos != -1) 
				{
					positions[pos] = 1; //revert back at the end.
				}
				newpos = positions.slice();
				//newpos[2] = 1;
				if (boardmap[1][1] == 0) 
				{
					
					if(pos != -1)
						{ret = 4; middle = 4;} //checked.
					else 
						ret = 2;
					newpos[4] = 1;
					newpos[2] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 2;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[2] = 1;
				if (boardmap[0][1] == 0) {
					
					if(pos != -1)
						ret = 1;  //checked.
					else 
						ret = 2;
					newpos[1] = 1;
					newpos[2] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 2;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[2] = 1;
				if (boardmap[1][2]==0)  
				{
					
					if(pos != -1)
						ret = 5;  //checked.
					else 
						ret = 2;
					newpos[5] = 1;
					newpos[2] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 2;  //checked.
					}
				}
				
			}
			
			if ((pos == 3 || pos == -1) && positions[3]==player)
			{
				if (pos != -1) 
				{
					positions[pos] = 1; //revert back at the end.
				}
				newpos = positions.slice();
				//newpos[3] = 1;
				if (boardmap[1][1] == 0) 
				{
					
					if(pos != -1)
						{ret = 4;  middle = 4;}//checked.
					else 
						ret = 3;
					newpos[4] = 1;
					newpos[3] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 3;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[3] = 1;
				if (boardmap[0][0] == 0) {
					
					if(pos != -1)
						ret = 0;  //checked.
					else 
						ret = 3;
					newpos[0] = 1;
					newpos[3] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 3;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[3] = 1;
				if (boardmap[2][0]==0)  
				{
					
					if(pos != -1)
						ret = 7;  //checked.
					else 
						ret = 3;
					newpos[7] = 1;
					newpos[3] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 3;  //checked.
					}
				}
			}
			
			if ((pos == 4 || pos == -1) && positions[4]==player)
			{
				if (pos != -1) 
				{
					positions[pos] = 1; //revert back at the end.
				}
				newpos = positions.slice();
				//newpos[4] = 1;
				//need some awesome logic here. to be revisited
				if (boardmap[0][0] == 0) 
				{
					
					if(pos != -1)
						ret = 0;  //checked.
					else 
						ret = 4;
					newpos[0] = 1;
					newpos[4] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 4;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[4] = 1;
				if (boardmap[0][1] == 0) {
					
					if(pos != -1)
						ret = 1;  //checked.
					else 
						ret = 4;
					newpos[1] = 1;
					newpos[4] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 4;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[4] = 1;
				if (boardmap[0][2] == 0) {
					
					if(pos != -1)
						ret = 2;  //checked.
					else 
						ret = 4;
					newpos[2] = 1;
					newpos[4] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 4;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[4] = 1;
				if (boardmap[1][0]==0)  
				{
					
					if(pos != -1)
						ret = 3;  //checked.
					else 
						ret = 4;
					newpos[3] = 1;
					newpos[4] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 4;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[4] = 1;
				if (boardmap[1][2] == 0) {
					
					if(pos != -1)
						ret = 5;  //checked.
					else 
						ret = 4;
					newpos[5] = 1;
					newpos[4] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 4;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[4] = 1;
				if (boardmap[2][0] == 0) {
					
					if(pos != -1)
						ret = 6;  //checked.
					else 
						ret = 4;
					newpos[6] = 1;
					newpos[4] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 4;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[4] = 1;
				if (boardmap[2][1] == 0) {
					
					if(pos != -1)
						ret = 7;  //checked.
					else 
						ret = 4;
					newpos[7] = 1;
					newpos[4] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 4;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[4] = 1;
				if (boardmap[2][2] == 0) {
					
					if(pos != -1)
						ret = 8;  //checked.
					else 
						ret = 4;
					newpos[8] = 1;
					newpos[4] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 4;  //checked.
					}
				}
			}
			
			if ((pos == 5 || pos == -1) && positions[5]==player)
			{
				if (pos != -1) 
				{
					positions[pos] = 1; //revert back at the end.
				}
				newpos = positions.slice();
				//newpos[5] = 1;
				if (boardmap[1][1] == 0) 
				{
					
					if(pos != -1)
						{ret = 4; middle = 4;} //checked.
					else 
						ret = 5;
					newpos[4] = 1;
					newpos[5] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 5;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[5] = 1;
				if (boardmap[0][2] == 0) {
					
					if(pos != -1)
						ret = 2;  //checked.
					else 
						ret = 5;
					newpos[2] = 1;
					newpos[5] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 5;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[5] = 1;
				if (boardmap[2][2]==0)  
				{
					
					if(pos != -1)
						ret = 8;  //checked.
					else 
						ret = 5;
					newpos[8] = 1;
					newpos[5] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 5;  //checked.
					}
				}
			}
			
			if ((pos == 6 || pos == -1) && positions[6]==player)
			{
				if (pos != -1) 
				{
					positions[pos] = 1; //revert back at the end.
				}
				newpos = positions.slice();
				//newpos[6] = 1;
				if (boardmap[1][1] == 0) 
				{
					
					if(pos != -1)
						{ret = 4; middle = 4;} //checked.
					else 
						ret = 6;
					newpos[4] = 1;
					newpos[6] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 6;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[6] = 1;
				if (boardmap[2][1] == 0) {
					
					if(pos != -1)
						ret = 7;  //checked.
					else 
						ret = 6;
					newpos[7] = 1;
					newpos[6] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 6;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[6] = 1;
				if (boardmap[1][0]==0)  
				{
					
					if(pos != -1)
						ret = 3;  //checked.
					else 
						ret = 6;
					newpos[3] = 1;
					newpos[6] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 6;  //checked.
					}
				}
			}
			
			if ((pos == 7 || pos == -1) && positions[7]==player)
			{
				if (pos != -1) 
				{
					positions[pos] = 1; //revert back at the end.
				}
				newpos = positions.slice();
				//newpos[7] = 1;
				if (boardmap[1][1] == 0) 
				{
					
					if(pos != -1)
						{ret = 4; middle = 4;} //checked.
					else 
						ret = 7;
					newpos[4] = 1;
					newpos[7] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 7;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[7] = 1;
				if (boardmap[2][2] == 0) {
					
					if(pos != -1)
						ret = 8;  //checked.
					else 
						ret = 7;
					newpos[8] = 1;
					newpos[7] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 7;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[7] = 1;
				if (boardmap[2][0]==0)  
				{
					
					if(pos != -1)
						ret = 6;  //checked.
					else 
						ret = 7;
					newpos[6] = 1;
					newpos[7] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2; return ret;
						}
						return 7;  //checked.
					}
				}
			}
			
			if ((pos == 8 || pos == -1) && positions[8]==player)
			{
				if (pos != -1) 
				{
					positions[pos] = 1; //revert back at the end.
				}
				newpos = positions.slice();
				//newpos[8] = 1;
				
				if (boardmap[1][1] == 0) 
				{
					if(pos != -1)
						{ret = 4;  middle = 4;}//checked.
					else 
						ret = 8;
					newpos[4] = 1;
					newpos[8] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2;
							return ret;
						}
						return 8;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[8] = 1;
				if (boardmap[2][1] == 0) {
					if(pos != -1)
						ret = 7;  //checked.
					else 
						ret = 8;
					
					newpos[7] = 1;
					newpos[8] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2;
							return ret;
						}
						return 8;  //checked.
					}
				}
				newpos = positions.slice();
				//newpos[8] = 1;
				if (boardmap[1][2]==0)  
				{
					if(pos != -1)
						ret = 5;  //checked.
					else 
						ret = 8;
					
					newpos[5] = 1;
					newpos[8] = 2;
					if (evaluateWinner(1, newpos) == 1) {
						if (pos != -1) 
						{
							positions[pos] = 2;
							return ret;
						}
						return 8;  //checked.
					}
				}
			}
			if (pos != -1) 
			{
				positions[pos] = 2;
			}
			if (pos != -1 && middle == 4) 
			{
				return 4;
			}
			return ret;
		}
	}

}