package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.Mask;
	import net.flashpunk.FP;
	
	/**
	 * ...
	 * @author Ragha
	 */
	public class MouseDetector extends Entity 
	{
		
		public function MouseDetector(x:Number = 0, y:Number = 0, graphic:Graphic = null, mask:Mask = null) {
			super(x, y, graphic, mask);
		}
		
		override public function update():void {
			super.update();
			
			if(collidePoint(this.x, this.y,  FP.screen.mouseX,  FP.screen.mouseY)) {
				trace("The mouse is over me!");
			}
		}
		
	}

}