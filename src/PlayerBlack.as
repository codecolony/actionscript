package 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	
	/**
	 * ...
	 * @author Ragha
	 */
	public class PlayerBlack extends Entity
	{
		[Embed(source = "assets/black_marble.png")] public const BLACK_MARBLE:Class;
		
		
		public var image:Image;
		public function PlayerBlack() 
		{
			image = new Image(BLACK_MARBLE);
			image.scale = 0.25;
			//image.drawMask = 0xffffff;
			
			this.graphic = image;
			x = FP.rand(FP.screen.width);
			y = FP.rand(FP.screen.height);
			type = "human";
		}
		
		override public function update():void 
		{
			//x = Input.mouseX-30;
			//y = Input.mouseY-30;
			
					
			super.update();
		}
		
	}

}