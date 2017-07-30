package;

import rgine.RGine;

class Main {
	public static function main() {
		#if js
		var canvas = cast(js.Browser.document.getElementById('khanvas'), js.html.CanvasElement);
		canvas.width = js.Browser.window.innerWidth;
		canvas.height = js.Browser.window.innerHeight;      
		#end
		RGine.start(new LDGame(), "LD Game");
	}
}
