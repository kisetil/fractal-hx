package;

import openfl.display.Bitmap;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.display.Sprite;

class Main extends Sprite
{
	var _shape:Shape;
	var _fractal:Fractal;
	var _bitmap:Bitmap;

	var x0:Float;
	var y0:Float;

	var x1:Float;
	var y1:Float;

	var isPressed = false;

	public function new()
	{
		super();

		_fractal = new Fractal();

		stage.addEventListener(Event.RESIZE, (event) ->
		{
			removeChild(_shape);
			removeChild(_bitmap);

			_fractal.setBitmapSize(stage.stageWidth, stage.stageHeight);
			_bitmap = new Bitmap(_fractal.getBitmapData());
			addChild(_bitmap);

			_shape = new Shape();
			addChild(_shape);
		});

		stage.addEventListener(MouseEvent.MOUSE_DOWN, (event) ->
		{
			x0 = event.localX;
			y0 = event.localY;
			isPressed = true;
		});

		stage.addEventListener(MouseEvent.MOUSE_UP, (event) ->
		{
			_shape.graphics.clear();

			isPressed = false;
			x1 = event.localX;
			y1 = event.localY;

			_fractal.setNewRectPosition(x0, y0, x1, y1);
		});

		stage.addEventListener(MouseEvent.MOUSE_MOVE, (event) ->
		{
			if (isPressed)
			{
				x1 = event.localX;
				y1 = event.localY;

				_shape.graphics.clear();
				_shape.graphics.beginFill(0xFFFF00, 0.7);
				_shape.graphics.drawRect(x0, y0, x1 - x0, y1 - y0);
				_shape.graphics.endFill();
			}
		});

		stage.addEventListener(Event.ENTER_FRAME, (event) ->
		{
			_fractal.step();
		});
	}
}
