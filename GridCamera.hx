package ;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxPoint;

class GridCamera
{
	public var isMoving:Bool;
	
	public var currentGridX:Int;
	public var currentGridY:Int;
	
	private var actor:FlxSprite;
	
	private var mapWidthInPixels:Int;
	private var mapHeightInPixels:Int;
	
	private var numberOfGridsX:Int;
	private var numberOfGridsY:Int;
	
	private var gridsX:Array<Int>;
	private var gridsY:Array<Int>;
	
	private var cameraWidth:Int;
	private var cameraHeight:Int;
	
	private var transitionTime:Float;
	
	private var camera:FlxCamera;
	
	public function new(actor:FlxSprite, mapWidthInTiles:Int, mapHeightInTiles:Int, tileSize:Int, camera:FlxCamera, currentGridX:Int=0, currentGridY:Int=0, transitionTime:Float=1.5) 
	{
		this.actor = actor;
		
		mapWidthInPixels = mapWidthInTiles * tileSize;
		mapHeightInPixels = mapHeightInTiles * tileSize;
		
		numberOfGridsX = Std.int(mapWidthInPixels / camera.width);
		numberOfGridsY = Std.int(mapHeightInPixels / camera.height);
		
		gridsX = new Array<Int>();
		gridsY = new Array<Int>();
		isMoving = false;
		
		this.camera = camera;
		
		this.currentGridX = currentGridX;
		this.currentGridY = currentGridY;
		
		this.cameraWidth = camera.width;
		this.cameraHeight = camera.height;
		
		this.transitionTime = transitionTime;
	}
	
	public function set(x:Int=0, y:Int=0):Void
	{
		camera.setBounds(x, y, mapWidthInPixels, mapHeightInPixels, true);
		if(currentGridX != 0 || currentGridY != 0) {
			FlxG.camera.scroll.x = currentGridX * cameraWidth;
			FlxG.camera.scroll.y = currentGridY * cameraHeight;
		}
		for (i in 0...numberOfGridsX) {
			gridsX.push(i * cameraWidth);
		}
		for (i in 0...numberOfGridsY) {
			gridsY.push(i * cameraHeight);
		}
	}
	
	public function setTransitionTime(time:Float):Void
	{
		transitionTime = time;
	}
	
	public function getBounds():FlxPoint
	{
		return new FlxPoint(mapWidthInPixels, mapHeightInPixels);
	}
	
	public function getWidth():Int
	{
		return cameraWidth;
	}

	public function getHeight():Int
	{
		return cameraHeight;
	}
	
	public function update():Void
	{
		if (actor.x >= gridsX[currentGridX] + cameraWidth - actor.width && actor.x < mapWidthInPixels - actor.width && !isMoving) {
			isMoving = true;
			var tween = FlxTween.tween(FlxG.camera.scroll, { x: FlxG.camera.scroll.x + cameraWidth }, transitionTime);
			FlxTween.tween(actor, { x: actor.x + actor.width }, transitionTime);
			tween.complete = function(t:FlxTween) {
				currentGridX += 1;
				isMoving = false;
			};
		} else if (actor.x < gridsX[currentGridX] && actor.x > 0 && !isMoving) {
			isMoving = true;
			var tween = FlxTween.tween(FlxG.camera.scroll, { x: FlxG.camera.scroll.x - cameraWidth }, transitionTime);
			FlxTween.tween(actor, { x: actor.x - actor.width }, transitionTime);
			tween.complete = function(t:FlxTween) {
				currentGridX -= 1;
				isMoving = false;
			};
		}
		if (actor.y >= gridsY[currentGridY] + cameraHeight - actor.height && actor.y < mapHeightInPixels - actor.height && !isMoving) {
			isMoving = true;
			var tween = FlxTween.tween(FlxG.camera.scroll, { y: FlxG.camera.scroll.y + cameraHeight }, transitionTime);
			FlxTween.tween(actor, { y: actor.y + actor.height }, transitionTime);
			tween.complete = function(t:FlxTween) {
				currentGridY += 1;
				isMoving = false;
			};
		} else if (actor.y < gridsY[currentGridY] && actor.y > 0 && !isMoving) {
			isMoving = true;
			var tween = FlxTween.tween(FlxG.camera.scroll, { y: FlxG.camera.scroll.y - cameraHeight }, transitionTime);
			FlxTween.tween(actor, { y: actor.y - actor.height }, transitionTime);
			tween.complete = function(t:FlxTween) {
				currentGridY -= 1;
				isMoving = false;
			};
		}
	}
	
	public function destroy():Void 
	{
		actor.destroy();
		#if (cpp)
			gridsX.splice(0, gridsX.length);
			gridsY.splice(0, gridsY.length);
		#else
			untyped gridsX.length = 0;
			untyped gridsY.length = 0;
		#end
	}
}
