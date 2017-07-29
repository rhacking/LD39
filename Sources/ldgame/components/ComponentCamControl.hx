package ldgame.components;

import rgine.Component;
import rgine.Input;
import kha.input.KeyCode;

class ComponentCamControl extends Component {
	private static var SPEED(default, never) = 5.0;

	override public function update(delta:Float) {
		if (Input.isKeyDown(KeyCode.A)) this.object.translate(-delta*SPEED, 0, 0);
		if (Input.isKeyDown(KeyCode.D)) this.object.translate(delta*SPEED, 0, 0);
	
		if (Input.isKeyDown(KeyCode.W)) this.object.translate(0, 0, -delta*SPEED);
		if (Input.isKeyDown(KeyCode.S)) this.object.translate(0, 0, delta*SPEED);
	}
}