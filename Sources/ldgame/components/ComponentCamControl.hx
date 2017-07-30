package ldgame.components;

import rgine.Component;
import rgine.Input;

import kha.input.KeyCode;
import kha.math.FastVector3;

import rgine.components.ComponentRayCollider;
import rgine.components.ComponentCamera;

import kha.Framebuffer;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.math.FastMatrix4;

import rgine.gfx.Camera.DefaultCamera;

class ComponentCamControl extends Component {
	private static var SPEED(default, never) = 5.0;
	private var lookDir : FastVector3;

	override public function init() {
		lookDir = new FastVector3(0, -1, 0);
		this.object.addComponent(new ComponentRayCollider(lookDir));
	}

	private var frame : Framebuffer;
	
	override public function update(delta:Float) {
		if (Input.isKeyDown(KeyCode.A)) this.object.translate(-delta*SPEED, 0, 0);
		if (Input.isKeyDown(KeyCode.D)) this.object.translate(delta*SPEED, 0, 0);
	
		if (Input.isKeyDown(KeyCode.W)) this.object.translate(0, 0, -delta*SPEED);
		if (Input.isKeyDown(KeyCode.S)) this.object.translate(0, 0, delta*SPEED);

		var currentCamera:DefaultCamera = cast this.object.getComponent(ComponentCamera).camera;

		var proj = FastMatrix4.perspectiveProjection(currentCamera.fov, currentCamera.aspect, 0.01, 100.0);

		if (frame == null) return;

		var mouse = Input.getMouseCoords();
		var ndcRay = new FastVector3(mouse.x/frame.width*2-1, -(mouse.y/frame.height*2-1), -1);
		var viewDir = (proj.inverse().multvec(new FastVector4(ndcRay.x, ndcRay.y, ndcRay.z, 1)));
		viewDir.z = -1;
		viewDir.w = 0;
		var rayDir = this.object.transform.matrix.multvec(viewDir);
		rayDir.normalize();

		lookDir.x = rayDir.x;
		lookDir.y = rayDir.y;
		lookDir.z = rayDir.z;
	}

	override public function preDraw(frame:Framebuffer) {
		this.frame = frame;
	}
}