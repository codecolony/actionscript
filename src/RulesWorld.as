package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.World;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Input;
	
	/**
	 * ...
	 * @author Ragha
	 */
	
	
	
	public class RulesWorld extends World 
	{
		[Embed(source = "assets/rules740.PNG")] private const RULE_IMAGE:Class;
	
		private var rule_image:Image = new Image(RULE_IMAGE);
		private var rule_entity:Entity = new Entity(0, 30, rule_image);
		public function RulesWorld() 
		{
			FP.screen.color = 0;
			add(rule_entity);
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