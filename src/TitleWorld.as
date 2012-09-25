package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.World;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Input;
	import net.flashpunk.graphics.Text;
	
	/**
	 * ...
	 * @author Ragha
	 */
	public class TitleWorld extends World 
	{
		[Embed(source = "assets/trapemlogo.png")] private const INTRO:Class;
		[Embed(source = "assets/clicktoplay2.png")] private const CLICK_TO_PLAY:Class;
		private var intro:Image;
		private var play:Image;
		private var board:Entity;
		private var control:Entity;
		
		//private var control:Text = new Text("click to play!", 210, 440);
		
		public function TitleWorld() 
		{
			intro = new Image(INTRO);
			play = new Image(CLICK_TO_PLAY);
			play.scale = 0.6;
			//intro.scale = 0.85;
			board = new Entity(0, 0, intro);
			control = new Entity(210, 435, play);
			FP.screen.color = 0;// 0xffffffff;
			
			add(board);
			add(control);
			
	
			//control.color = 0;
			//control.size = 30;
			
			//addGraphic(control);
		}
		
		override public function update():void 
		{
			if (Input.mousePressed) 
			{
				FP.world = new GameWorld();
			}
			super.update();
		}
		
	}

}