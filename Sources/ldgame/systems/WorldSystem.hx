package ldgame.systems;

import rgine.systems.System;
import kha.graphics2.*;
import kha.*;
import kha.math.FastVector3;

import ldgame.states.StateGame;
import ldgame.components.ComponentExplosion;

import rgine.*;
import rgine.components.*;

import zui.*;
import haxe.ds.Vector;

class WorldSystem extends System {
	private var ui : Zui;

	private var mEnergy = 200;
	private var population = 0.0;
	private var money = 100;
	private static var TAX(default, never) = 5;

	private var globalVis = 1000;

	public function new() {}

	override public function initSys() {
		ui = new Zui({font: Assets.fonts.OpenSans_Regular, scaleFactor: 1.0});
		kha.input.Mouse.get(0).notify(mouseDown, null, null, null);
	}

	private var selected : GameObject = null;

	public function mouseDown(button, x, y) {
		if (dialogHover) return;
		if (button == 0 && selected != null) {
			var type = HexType.createByName(currentHexType);
			if (type == selected.getComponent(ldgame.components.ComponentTile).hex.type) return;
			var cost = StateGame.costs[type];
			if (cost <= money) {
				selected.getComponent(ldgame.components.ComponentTile).hex.type = type;
				money -= cost;
				var s = kha.audio1.Audio.play(kha.Assets.sounds.pick);
				if (s != null) s.volume = 0.3;
			}
		}
	}

	private var time = 85.0;
	private var acc = 0.0;
	private static var TIME_STEP(default, never) = 1.5;

	private var won = false;

	override public function update(delta:Float) {
		if (money < 0 || time >= 88) {
			if (fade == 0) {
				motion.Actuate.tween(this, 5, {fade: 1});
				if (time >= 88) {
					won = true;
					motion.Actuate.timer(0.6).onComplete(function() {
						var s = kha.audio1.Audio.play(kha.Assets.sounds.win);
						if (s != null) s.volume = 1.1;
					});
				} else {
					motion.Actuate.timer(0.6).onComplete(function() {
						var s = kha.audio1.Audio.play(kha.Assets.sounds.lose);
						if (s != null) s.volume = 1.1;
					});
				}
			}
			
			return;
		}
		selected = null;
		for (obj in scene.objects) {
			if (obj.getComponent(ldgame.components.ComponentTile) != null) {
				var cols = obj.getComponent(ComponentCollider).collidingWith;
				if (Lambda.exists(cols, function(obj) return obj.name == "cam")) selected = obj;
				obj.transform.position.y = 0.0;
				obj.getComponent(ldgame.components.ComponentTile).selected = false;
			}
		}

		if (selected != null && !dialogHover) {
			selected.getComponent(ldgame.components.ComponentTile).selected = true;
		}

		if (playing) {
			acc += delta*1.8;
			time += delta*1.8;
		}

		var hexes = LDGame.game.hexes;

		if (acc >= TIME_STEP) {
			acc = 0;

			var newTypes = new Vector<Vector<HexType>>(hexes.length);
			for (x in 0...hexes.length) {
				newTypes[x] = new Vector<HexType>(hexes[x].length);
			}
			
			updateBoard(hexes, newTypes);
			
			for (x in 0...hexes.length) {
				for (y in 0...hexes[x].length) {
					if (newTypes[x][y] != null) hexes[x][y].type = newTypes[x][y];
				}
			}
		}
		population = 0;
		for (x in 0...hexes.length) {
			for (y in 0...hexes[x].length) {
				var hex = hexes[x][y];
				switch (hex.type) {
					case Grass:

					case Village:
						population++;
					default:
				}
			}
		}
	}

	private function updateBoard(hexes : Vector<Vector<Hex>>, newTypes : Vector<Vector<HexType>>, anims=true) {
		if (mEnergy <= 0) money -= 10;
		for (x in 0...hexes.length) {
			for (y in 0...hexes[x].length) {
				var hex = hexes[x][y];
				switch (hex.type) {
					case Grass:
					case Village:
						if (this.mEnergy < 5) {
							if (Math.random() < 0.1) {
								newTypes[x][y] = Grass;
								var pos = hexes[x][y].object.transform.position;
								if (anims) this.scene.createObject("explosion").addComponent(new ComponentExplosion()).translate(pos.x, pos.y+0.5, pos.z);
								this.money -= 50;
							}
							this.money -= 5;
							continue;
						}
						var neighbours = getNeighbours(hexes, x, y);
						this.mEnergy -= 5;
						var villageCount = 0;
						for (neighCoords in neighbours) {
							var neigh = getHex(hexes, neighCoords[0], neighCoords[1]);
							if (neigh.type == Village) villageCount++;
						}
						this.money += Std.int(TAX + TAX*0.25*villageCount);
					case VisMine:
						var neighbours = getNeighbours(hexes, x, y);
						if (globalVis <= 0) {
							for (neighCoords in neighbours) {
								newTypes[neighCoords[0]][neighCoords[1]] = Water;
							}
							newTypes[x][y] = Water;
							var pos = hexes[x][y].object.transform.position;
							if (anims) this.scene.createObject("explosion").addComponent(new ComponentExplosion()).translate(pos.x, pos.y+0.5, pos.z);
							continue;
						}
						mEnergy += 10;
						globalVis -= 10;
						money -= Std.int(10 * (10/globalVis));
						
						var nearWater = false;
						for (neighCoords in neighbours) {
							var neigh = getHex(hexes, neighCoords[0], neighCoords[1]);
							if (neigh.type == Water) nearWater = true;
							if (neigh.type == Village && Math.random() < 0.1) newTypes[neighCoords[0]][neighCoords[1]] = Water;
						}
						if (!nearWater && Math.random() < 0.01) {
							for (neighCoords in neighbours) {
								newTypes[neighCoords[0]][neighCoords[1]] = Water;
							}
							newTypes[x][y] = Water;
							var pos = hexes[x][y].object.transform.position;
							if (anims) this.scene.createObject("explosion").addComponent(new ComponentExplosion()).translate(pos.x, pos.y+0.5, pos.z);
						}
					case SolemCollector:
						mEnergy += Std.int(Math.min(18, 10 + Std.int(time/5)));
						money -= 12;
						if (time > 50) {
							if (Math.random() < (time-50)/38/4.5) {
								newTypes[x][y] = Water;
								var pos = hexes[x][y].object.transform.position;
								if (anims) this.scene.createObject("explosion").addComponent(new ComponentExplosion()).translate(pos.x, pos.y+0.5, pos.z);
								money -= 40;
							}
						}
						var neighbours = getNeighbours(hexes, x, y);
						var solemCount = 0;
						for (neighCoords in neighbours) {
							var neigh = getHex(hexes, neighCoords[0], neighCoords[1]);
							if (neigh.type == SolemCollector) solemCount++;
						}
						money -= 12 - Std.int(solemCount/2);
					default:
				}
			}
		}
	}

	private function getNeighbours(hexes, x, y) {
		var neighbours = [];
		if (getHex(hexes, x-1, y) != null) neighbours.push([x-1, y]);
		if (getHex(hexes, x+1, y) != null) neighbours.push([x+1, y]);
		if (getHex(hexes, x, y-1) != null) neighbours.push([x, y-1]);
		if (getHex(hexes, x, y+1) != null) neighbours.push([x, y+1]);

		if (y & 2 != 0) {
			if (getHex(hexes, x-1, y-1) != null) neighbours.push([x-1, y-1]);
			if (getHex(hexes, x-1, y+1) != null) neighbours.push([x-1, y+1]);
		} else {
			if (getHex(hexes, x+1, y-1) != null) neighbours.push([x+1, y-1]);
			if (getHex(hexes, x+1, y+1) != null) neighbours.push([x+1, y+1]);
		}

		return neighbours;
	}

	private function getHex(hexes:Vector<Vector<Hex>>, x, y) {
		if (x > -1 && y > -1 && x < hexes.length && y < hexes[x].length) return hexes[x][y];
		return null;
	}

	override public function draw(frame:Framebuffer) {
		var pipeline = rgine.gfx.Pipelines.DEFAULT;
		frame.g4.setPipeline(pipeline.pipelineState);
		frame.g4.setVector3(pipeline.getLocation("lightDir"), new FastVector3(-0.4, -0.7, -0.4));
		frame.g4.setVector3(pipeline.getLocation("lightIntensity"), new FastVector3(0.15, 0.15, 0.15));
	}

	private var currentHexType : String;
	private var timeMult = 1.0;
	private var fade = 0.0;
	private var playing = false;

	private var dialogHover = false;

	override public function draw2(g:Graphics, frame:Framebuffer) {
		dialogHover = false;

		ui.begin(g);
		var infoWin = Id.handle();
		infoWin.redraws = 1;
		var deltaMoney = 0.0;
		var deltaMEnergy = 0.0;
		var deltaVis = 0.0;
		for (i in 0...4) {
			var oldMoney = money;
			var oldMEnergy = mEnergy;
			var oldGlobalVis = globalVis;

			var hexes = LDGame.game.hexes;
			var newTypes = new Vector<Vector<HexType>>(hexes.length);
			for (x in 0...hexes.length) {
				newTypes[x] = new Vector<HexType>(hexes[x].length);
			}

			updateBoard(hexes, newTypes, false);

			deltaMoney += money - oldMoney;
			deltaMEnergy += mEnergy - oldMEnergy;
			deltaVis += globalVis - oldGlobalVis;

			this.money = oldMoney;
			this.mEnergy = oldMEnergy;
			this.globalVis = oldGlobalVis;
		}

		deltaMoney /= 4;
		deltaMEnergy /= 4;
		deltaVis /= 4;

		if (ui.window(infoWin, 8, 8, 300, 400, true)) {
			ui.text('Magical energy: $mEnergy');
			ui.text('Money: $money');
			ui.text('Global vis: $globalVis');

			ui.text('Delta energy: $deltaMEnergy');
			ui.text('Delta money: $deltaMoney');
			ui.text('Delta vis: $deltaVis');

			ui.text('Population: $population');

			ui.text('Selected: ${selected == null ? 'None' : selected.getComponent(ldgame.components.ComponentTile).hex.type.getName()}');
		}
		if (ui.getInputInRect(ui._windowX, ui._windowY, ui._windowW, ui._windowH)) dialogHover = true;

		var selectorWin = Id.handle();
		if (ui.window(selectorWin, 8, 300, 200, 400, true)) {
			var radioHandle = Id.handle();
			var i = 0;
			for (type in HexType.getConstructors()) {
				if (ui.radio(radioHandle, i++, type)) currentHexType = type;
			}
		}
		if (ui.getInputInRect(ui._windowX, ui._windowY, ui._windowW, ui._windowH)) dialogHover = true;

		var timeWin = Id.handle();
		timeWin.redraws = 1;
		if (ui.window(timeWin, 320, 8, 200, 110, true)) {
			if (ui.button("Next")) {
				acc += TIME_STEP;
				time += TIME_STEP;
			}
			if (ui.button(playing ? "Stop" : "Play")) playing = !playing;
			ui.separator();
			ui.text('Year: ${Math.floor(time)}');
		}
		if (ui.getInputInRect(ui._windowX, ui._windowY, ui._windowW, ui._windowH)) dialogHover = true;

		var helpWin = Id.handle();
		if (ui.window(helpWin, 8, 600, 400, 400, true)) {
			var hcombo = Id.handle();
			var choice = ui.combo(hcombo, [for (key in helpTexts.keys()) key]);

			renderMultiLineText(helpTexts[[for (key in helpTexts.keys()) key][choice]], 32);
		}
		if (ui.getInputInRect(ui._windowX, ui._windowY, ui._windowW, ui._windowH)) dialogHover = true;
		ui.end();

		frame.g2.begin(false);
		frame.g2.color = kha.Color.fromFloats(0, 0, 0, fade);
		frame.g2.fillRect(0, 0, frame.width, frame.height);
		frame.g2.color = kha.Color.fromFloats(1, 1, 1, fade);
		frame.g2.fontSize = 60;
		frame.g2.font = kha.Assets.fonts.OpenSans_Regular;
		var text = won ? "You win!" : "Game Over";
		frame.g2.drawString(text, frame.width/2-kha.Assets.fonts.OpenSans_Regular.width(60, text)/2, frame.height/2);
		frame.g2.end();
	}

	private var helpTexts = [
		"General" => "The goal of the game is to build a world that is capable of sustaining itself without the use of Vis. In order to achieve this, you must replace Vis mines with a different source of energy. At the end of the game, If you manage to get to year 88 without running out of money, you win. ",
		"VisMine" => "Vis mines produce 10 energy every turn, and cost more money as they use up all Vis. There is also a random chance that a village nearby will be turned into a water tile. If a mine is not next to water, there is a chance it will explode. It will also explode if there is no Vis left in the world. ", 
		"Village" => "Villages generate money every turn (more if they are next to other villages) and they consume 5 energy every turn. If there is no energy left, the villages will cause various negative effects. ", 
		"SolemCollector" => "Solem collectors produce 10 + year/5 energy and cost 12 dollars per turn. As time goes on they may also explode (though they will not affect neighbouring tiles), and this will also cost 40 dollars. "
	];

	public function renderMultiLineText(text : String, limit : Int) {
		var current = "";
		var index = 0;
		while (index < text.length) {
			var c = text.charAt(index);
			current += c;
			if (c == ' ' && current.length >= limit) {
				ui.text(current);
				current = "";
			}
			index++;
		}
		if (StringTools.trim(current).length > 0) ui.text(current);
	}
}