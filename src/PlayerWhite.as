package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	/**
	 * ...
	 * @author Ragha
	 */
	public class PlayerWhite extends Entity
	{
		[Embed(source = "assets/w_marble.png")] public const WHITE_MARBLE:Class;
		public var image:Image;
		public function PlayerWhite() 
		{
			image = new Image(WHITE_MARBLE);
			this.graphic = image;
			image.scale = 0.25;
			x = FP.rand(FP.screen.width);
			y = FP.rand(FP.screen.height);
			type = "computer";
		}
		
	}

}