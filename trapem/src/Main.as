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
		public function Main():void 
		{
			super(760, 480);
			//FP.console.enable();
			
		}
		
		override public function init():void {
			
			trace("Flashpunk has initialized");
			FP.world = new TitleWorld();
			super.init();
		}
	}
	
}