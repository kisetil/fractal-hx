package;

import openfl.display.BitmapData;
import numerics.Complex;

class Fractal
{
	var _state = FractalState.Idle;
	var _bitmapData:BitmapData;
	var _actualLine:Int;

	// Starting point
	var xmin:Float = -2.0;
	var xmax:Float = 1.0;
	var ymin:Float = -1.0;
	var ymax:Float = 1.0;

	var _width:Float;
	var _height:Float;

	var _maxIter = 100;

	public function new() {}

	public function setBitmapSize(width:Int, height:Int)
	{
		_bitmapData = new BitmapData(width, height, false, 0xFF000000);
		_width = width;
		_height = height;
		_actualLine = 0;
		_state = FractalState.Restart;
	}

	public function setNewRectPosition(x0:Float, y0:Float, x1:Float, y1:Float)
	{
		var topleft = getFractalCoordsFromViewPortCoords(x0, y0);
		var bottomright = getFractalCoordsFromViewPortCoords(x1, y1);

		xmin = topleft.x;
		xmax = bottomright.x;
		ymin = topleft.y;
		ymax = bottomright.y;

		_actualLine = 0;
		_state = FractalState.Restart;
	}

	public inline function getBitmapData():BitmapData
	{
		return _bitmapData;
	}

	public inline function getState():FractalState
	{
		return _state;
	}

	// the core of the application
	function getPixelAt(c:Complex):Int
	{
		var z = new Complex(0, 0);
		var it = 0;

		do
		{
			z = z * z + c;
			it++;
		}
		while (Complex.norm(z) < 4.0 && it < _maxIter);

		return it;
	}

	inline function getRGB(i:Int):Int
	{
		var color:Int;
		var r:Int;
		var g:Int;
		var b:Int;

		color = cast 255 * i / _maxIter;
		r = cast color * 0.75;
		g = cast color; //* 0.75;
		b = cast color * 0.75;

		return (r << 16) | (g << 8) | b;
	}

	inline function getFractalCoordsFromViewPortCoords(px:Float, py:Float):{x:Float, y:Float}
	{
		return {
			x: xmin + (xmax - xmin) * px / (_width - 1),
			y: ymin + (ymax - ymin) * py / (_height - 1)
		};
	}

	function computeLine(line:Int):Void
	{
		_bitmapData.lock();

		for (y in 0...10)
		{
			for (x in 0..._bitmapData.width)
			{
				var coordPos = getFractalCoordsFromViewPortCoords(x, line + y);

				var i = getPixelAt(new Complex(coordPos.x, coordPos.y));
				var color:Int;

				if (i == _maxIter)
				{
					color = 0x000000;
				}
				else
				{
					color = getRGB(i);
				}

				_bitmapData.setPixel(x, line + y, color);
			}
		}
		_bitmapData.unlock();
	}

	public function step():Void
	{
		if (_state == FractalState.Idle)
		{
			// do nothing !
		}
		else if (_state == FractalState.Working)
		{
			computeLine(_actualLine);
			_actualLine += 10;

			if (_actualLine > _bitmapData.height)
				_state = FractalState.Idle;
		}
		else if (_state == FractalState.Restart)
		{
			// after restart internal states
			_state = FractalState.Working;
		}
	}
}
