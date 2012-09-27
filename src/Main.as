package 
{
import net.flashpunk.Engine;
import net.flashpunk.FP;

	/**
	 * ...
	 * @author Ragha
	 */
	public class Main extends Engine 
	{
		//[Embed(source = 'assets/intro.swf')] private var _movie:Class;
		//public var introMovieClip:MovieClip;
		
		//private var intro:Intro = new Intro();
		public function Main():void 
		{
			super(760, 480);
			//FP.screen.scale = 1.1;
			//FP.console.enable();
			
		}
		
		override public function init():void {
			
			trace("Flashpunk has initialized");
			
			//introMovieClip = new _movie();
			//introMovieClip.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			//introMovieClip.x = 640;
			//introMovieClip.y = 480;
			//FP.stage.addChild(introMovieClip);
			
			//FP.world = new GameWorld();
			FP.world = new TitleWorld();
			super.init();
		}
		
		/*private function onAddedToStage(event:Event):void
		{
			introMovieClip.play(); // does nothing!
			
			introMovieClip.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			introMovieClip.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			trace(introMovieClip.totalFrames); // return a blank!

		}
		
		private function onRemovedFromStage(event:Event):void
		{
			//introMovieClip.stop();
			introMovieClip.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			introMovieClip.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			introMovieClip.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			FP.world = new GameWorld();
		}
		
		private function onEnterFrame(event:Event):void
		{
			trace(introMovieClip.currentFrame); // return a blank!
			
			if (introMovieClip.currentFrame == introMovieClip.totalFrames) 
			{
				
				var myTimer:Timer = new Timer(5000, 0);
				myTimer.addEventListener(TimerEvent.TIMER, timerListener);
				myTimer.start();
				
			}
		}
		
		private function timerListener (e:TimerEvent):void
		{
				trace("Timer is Triggered");
				FP.stage.removeChild(introMovieClip);
		}*/
		
	}
	
}