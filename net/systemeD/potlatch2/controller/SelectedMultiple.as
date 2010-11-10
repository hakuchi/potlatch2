package net.systemeD.potlatch2.controller {
	import flash.events.*;
	import flash.display.DisplayObject;
	import flash.ui.Keyboard;
	import net.systemeD.potlatch2.EditController;
	import net.systemeD.halcyon.connection.*;
	import net.systemeD.halcyon.MapPaint;
	import net.systemeD.halcyon.WayUI;
	import net.systemeD.halcyon.Globals;

	public class SelectedMultiple extends ControllerState {
		protected var initSelection:Array;
		
		public function SelectedMultiple(sel:Array) {
			initSelection=sel.concat();
		}

		override public function processMouseEvent(event:MouseEvent, entity:Entity):ControllerState {
			if (event.type==MouseEvent.MOUSE_MOVE || event.type==MouseEvent.ROLL_OVER || event.type==MouseEvent.MOUSE_OUT) { return this; }
			var focus:Entity = getTopLevelFocusEntity(entity);

			if ( event.type == MouseEvent.MOUSE_DOWN && event.ctrlKey ) {
				// modify selection
				controller.map.setHighlight(entity, { selected: toggleSelection(entity) });

				if      (selectCount> 1) { return this; }
				else if (selectCount==1) {
					if (firstSelected is Way) {
						return new SelectedWay(firstSelected as Way);
					} else if (firstSelected is Node && Node(firstSelected).hasParentWays) {
						var way:Way=firstSelected.parentWays[0] as Way;
						return new SelectedWayNode(way, way.indexOfNode(firstSelected as Node));
					} else {
						return new SelectedPOINode(firstSelected as Node);
					}
				} else {
					return new NoSelection();
				}
			}
			var cs:ControllerState = sharedMouseEvents(event, entity);
			return cs ? cs : this;
		}

		override public function enterState():void {
			selection=initSelection.concat();
			for each (var entity:Entity in selection) {
				controller.map.setHighlight(entity, { selected: true, hover: false });
			}
			controller.updateSelectionUI();
			controller.map.setPurgable(selection,false);
			Globals.vars.root.addDebug("**** -> "+this+" "+selection);
		}

		override public function exitState(newState:ControllerState):void {
			controller.map.setPurgable(selection,true);
			for each (var entity:Entity in selection) {
				controller.map.setHighlight(entity, { selected: false, hover: false });
			}
			selection = [];
			if (!newState.isSelectionState()) { controller.updateSelectionUI(); }
			Globals.vars.root.addDebug("**** <- "+this);
		}

		override public function toString():String {
			return "SelectedMultiple";
		}

	}
}