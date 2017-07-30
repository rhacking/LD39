package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import rgine.Game;
import rgine.util.StateManager;

import ldgame.states.*;

class LDGame extends Game {
	var stateMan : StateManager;

	public static var game : StateGame;

	public function new() {}

	override function init() : Void {
		stateMan = new StateManager();
		game = new StateGame();
		stateMan.addState("GAME", game);
		stateMan.setState("GAME");
	}

	override function update(delta) : Void {
		stateMan.update(delta);
	}

	override function draw(frame : Framebuffer) : Void {
		stateMan.draw(frame);
	}
}
