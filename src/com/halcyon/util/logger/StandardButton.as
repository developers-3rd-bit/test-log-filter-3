package com.halcyon.util.logger
{
	import com.greensock.TweenMax;
	import com.greensock.data.TweenMaxVars;
	import com.greensock.easing.*;
	import com.halcyon.util.events.EventManager;
	import com.halcyon.util.events.HalcyonEvent;
	import com.halcyon.util.utilities.LogFactory;
	import com.halcyon.util.utilities.Logger;
	import com.halcyon.util.utilities.MathUtils;
	import com.halcyon.util.utilities.TextUtil;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class StandardButton
	{

		public static const PIN_NONE:int = 0;
		public static const PIN_RIGHT:int = 1;
		public static const PIN_LEFT:int = 2;
		public static const PIN_MIDDLE:int = 3;
		public static const MARGIN:int = 26;
		
		private var log:Logger = LogFactory.getLog("StandardButton", Logger.WARN);
		private static const TEXT_GUTTER:int = 10;
		private static const TWEEN_TIME:Number = 0.15;
		
		private var _upStateBkgColor:Number = 0x333333;
		private var _inactiveBkgColor:Number;
		private var _inactiveTextColor:Number;
		private var _normalTextColor:Number;
		private var tlSymbol:MovieClip
		private var buttonRoot:MovieClip;
		private var bg:MovieClip;
		private var upStateImage:MovieClip;
		private var theText:MovieClip;
		private var colorTween:TweenMax;
		private var toolTip:String;
		private var toolTipClip:MovieClip;
		private var isActive:Boolean;
		private var smallWidth:Number;
		private var useHardToolTip:Boolean;
		private var theMask:Sprite;
		
		private var alphaInstead:Boolean = false;
		private var _labelField:TextField;
		private var _overTextColor:Number;
		private var textTween:TweenMax;
		
		
		public function StandardButton(button:MovieClip, buttonClip:MovieClip = null, buttonToolTip:String = null, upStateBkgColor:Number = 0x333333, inactiveBkgColor:Number = 0xCCCCCC, inactiveTextColor:Number = 0x9a9a9a, normalTextColor:Number = 0xCCCCCC, overTextColor:Number = 0xFFFFFF)
		{
			this._overTextColor = overTextColor;

			_upStateBkgColor = upStateBkgColor;
			_inactiveBkgColor = inactiveBkgColor;
			_inactiveTextColor = inactiveTextColor;
			_normalTextColor = normalTextColor;
			
			buttonRoot = button;
			if(buttonClip == null){
				bg = buttonRoot;
			} else {
				bg = buttonClip;
			}
			
			if (bg.tlClip != null) {
				tlSymbol = bg.tlClip;
				tlSymbol.stop();
			} else {
				tlSymbol = null;
			}
			
			if (bg.mcUp != null) {
				alphaInstead = true;
			}
			
			toolTip = buttonToolTip;
			useHardToolTip = (toolTip == "useHardToolTip");
			buttonRoot.tabEnabled = false;
			
			upStateImage = bg.mcRollOver;
			theText = bg.textHolder;
			
			disableText(buttonRoot);
			//makeMask();
			
			if(bg.mcTooltip != null){
				toolTipClip = bg.mcTooltip;
				toolTipClip.visible = false;
				buttonRoot.addChild(toolTipClip);
			}
			
			findLabelTextField(this.buttonRoot);
			enable();
		}
		
		private function findLabelTextField(container:DisplayObjectContainer):void
		{
			var n:int = container.numChildren;
			for (var i:int = 0; i < n; i++)
			{
				var dispObj:DisplayObject = container.getChildAt(i);
				if (dispObj is TextField)
				{
					_labelField = dispObj as TextField;
					_labelField.autoSize = TextFieldAutoSize.LEFT;
					break;
				} else
				{
					if (dispObj is DisplayObjectContainer) findLabelTextField(dispObj as DisplayObjectContainer);
				}
			}
		}
		
		public function setLabel(value:String, resizeBkg:Boolean = false, minWidth:Number = 50, forceUpperCase:Boolean = true, pin:int = 0 ):void
		{
			try
			{
				var orgRight:Number = this.right;
				var orgLeft:Number = this.left;
				var orgMiddle:Number = this.middle;
				TextUtil.setText(_labelField, (forceUpperCase)?value.toUpperCase():value);
				if (resizeBkg)
				{
					var globPt:Point = _labelField.localToGlobal(new Point(0, 0));
					var upImage:Point = upStateImage.localToGlobal(new Point(0, 0));
					if (minWidth>=0)
					{
						upStateImage.width = MathUtils.max(minWidth, _labelField.width + (TEXT_GUTTER * 2));
						theText.x = MathUtils.round((upStateImage.width - theText.width) * .5);
					} else {
						//upStateImage.width = _labelField.width + ((globPt.x - upImage.x) * 2);
						upStateImage.width = _labelField.width + (TEXT_GUTTER * 2);
						theText.x = 10;
					}
					smallWidth = upStateImage.width;
					//makeMask();
				}
				switch (pin)
				{
					case PIN_NONE:
						//noop
						break;
					case PIN_RIGHT:
						this.right = orgRight;
						break;
					case PIN_LEFT:
						this.left = orgLeft;
						break;
					case PIN_MIDDLE:
						this.middle = orgMiddle;
				}
			} catch (e:Error)
			{
				/*no label field found*/
			}
			
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return this.buttonSource.hasEventListener(type);
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			this.buttonSource.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function):void
		{
			this.buttonSource.removeEventListener(type, listener);
		}
		
		public function enable():void {
			if(!isActive){
				buttonRoot.buttonMode = true;
				setupListeners();
				isActive = true;
				if (tlSymbol != null) {
					tlSymbol.gotoAndStop("up");
				}
			}
		}
		
		public function disable():void {
			if(isActive){
				buttonRoot.buttonMode = false;
				removeListeners();
				hideToolTip();
				isActive = false;
				if (tlSymbol != null) {
					tlSymbol.gotoAndStop("inactive");
				}
			}
		}
		
		
		private function makeMask():void {
			theMask = new Sprite();
			theMask.graphics.beginFill(0x000000, 0);
			theMask.graphics.drawRect(0, 0, upStateImage.width, upStateImage.height);
			theMask.graphics.endFill();
			buttonRoot.addChild(theMask);
			smallWidth = bg.mcRollOver.width;
			bg.mask = theMask;
		}
		
		private function setupListeners():void {
			TweenMax.to(theText, 0, { tint:_normalTextColor } );
			
			if (alphaInstead) {
				colorTween = TweenMax.fromTo( upStateImage,TWEEN_TIME, { alpha:0 }, { alpha:1, onCcomplete:showToolTip } );
			} else {
				colorTween = TweenMax.fromTo(upStateImage, TWEEN_TIME, { tint:_upStateBkgColor }, { removeTint:true, onComplete:showToolTip } );
				textTween = TweenMax.fromTo(theText, TWEEN_TIME, { tint: _normalTextColor } , { tint:_overTextColor } );
			}
			
			bg.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			bg.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			
			colorTween.currentProgress = 0.1;
			colorTween.reverse();
			textTween.currentProgress = 0.1;
			textTween.reverse();
		}
		
		private function removeListeners():void {
			
			bg.removeEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			bg.removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			//buttonRoot.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			//buttonRoot.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			colorTween = null;
			TweenMax.to(upStateImage, 0, { tint:_inactiveBkgColor } );
			TweenMax.to(theText, 0, { tint:_inactiveTextColor } );
		}
		
		private function disableText(obj:DisplayObjectContainer):void{
			for(var i:int = 0; i < obj.numChildren; i++){
				if(obj.getChildAt(i) is TextField){
					(obj.getChildAt(i) as TextField).mouseEnabled = false;
				} else if(obj.getChildAt(i) is DisplayObjectContainer){
					disableText(obj.getChildAt(i) as DisplayObjectContainer);
				}
			}
		}
		
		private function safeGoto(clip:MovieClip,label:String):void
		{
			try
			{
				clip.gotoAndStop(label);
			} catch (e:ArgumentError)
			{
				clip.stop();
			}
		}
		
		private function onMouseOver(e:Event):void {
			colorTween.play();
			textTween.play();
			if (tlSymbol != null) {
				tlSymbol.gotoAndStop("over");
			}
		}
		
		private function onMouseOut(e:Event):void{
			colorTween.reverse();
			textTween.reverse();
			hideToolTip();
			if (tlSymbol != null) {
				tlSymbol.gotoAndStop("up");
			}
		}
		
		private function onMouseDown(e:Event):void{
			
			//does nothing really
			if (tlSymbol != null) {
				tlSymbol.gotoAndStop("down");
			}
		}
		
		private function onMouseUp(e:Event):void{
				
			//does nothing really
			hideToolTip();
		}
		
		private function showToolTip():void {
			if (toolTip != null) {
				if(!useHardToolTip){
					var event:HalcyonEvent = new HalcyonEvent("TOOL_TIP_SHOW");
					var extra:Object = new Object();
					extra.text = toolTip;
					event.setExtra(extra);
					EventManager.getInstance().dispatchEvent(event);
				} else {
					toolTipClip.alpha = 0;
					toolTipClip.visible = true;
					TweenMax.to(toolTipClip, TWEEN_TIME, { alpha:1 } );
				}
			}
		}
		
		private function hideToolTip():void {
			if(toolTip != null){
				if(!useHardToolTip){
					var event:HalcyonEvent = new HalcyonEvent("TOOL_TIP_HIDE");
					EventManager.getInstance().dispatchEvent(event);
				} else {
					toolTipClip.visible = false;
				}
			}
		}
		
		
		public function get enabled():Boolean {
			return isActive;
		}
		
		public function set enabled(incomming:Boolean):void {
			if (incomming) {
				enable();
			} else {
				disable();
			}
		}
		
		public function get buttonSource():MovieClip {
			return buttonRoot;
		}
		
		public function get x():Number {
			return buttonRoot.x;
		}
		
		public function set x(incomming:Number):void {
			buttonRoot.x = incomming;
		}
		
		public function get right():Number
		{
			return buttonRoot.x + buttonRoot.width;
		}
		
		public function set right(value:Number):void
		{
			buttonRoot.x = value - buttonRoot.width;
		}
		
		public function get left():Number 
		{ 
			return buttonRoot.x; 
		}
		
		public function set left(value:Number):void
		{
			buttonRoot.x = value;
		}
		
		public function get middle():Number 
		{ 
			return buttonRoot.x + buttonRoot.width / 2; 
		}
		
		public function set middle(value:Number):void
		{
			buttonRoot.x = value - buttonRoot.width / 2;
		}
		
		public function get y():Number {
			return buttonRoot.y;
		}
		
		public function set y(incomming:Number):void {
			buttonRoot.y = incomming
		}
		
		public function get width():Number {
			return smallWidth;
		}
		
		public function set width(incomming:Number):void {
			buttonRoot.width = incomming;
		}
		
		public function get height():Number {
			return buttonRoot.height;
		}
		
		public function set height(incomming:Number):void {
			buttonRoot.height = incomming;
		}
		
		public function get visible():Boolean {
			return buttonRoot.visible;
		}
		
		public function set visible(incomming:Boolean):void {
			buttonRoot.visible = incomming;
		}
		
		public function get parent():DisplayObjectContainer { return buttonRoot.parent; }
		
		public function get tabIndex():int 
		{
			return buttonRoot.tabIndex;
		}
		
		public function set tabIndex(value:int):void 
		{
			buttonRoot.tabIndex = value;
		}
		
		public function get tabEnabled():Boolean 
		{
			return buttonRoot.tabEnabled;
		}
		
		public function set tabEnabled(value:Boolean):void 
		{
			buttonRoot.tabEnabled = value;
		}
	}
}