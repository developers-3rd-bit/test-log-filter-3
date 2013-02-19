package com.halcyon.util.logger
{
   import com.greensock.TweenMax;
   import com.halcyon.layout.common.HalcyonCanvas;
   import com.halcyon.layout.common.LayoutEvent;
   
   import fl.controls.CheckBox;
   
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class LoggerListItem extends HalcyonCanvas
   {
      public static const CHECKBOX_CLICK:String = "checkBoxClick";
      
      private var _bg:Sprite;
      private var _labelField:TextField;
      private var _textFormat:TextFormat;
      private var _selectCheckBox:CheckBox;
      private var _tween:TweenMax;
      
      public function LoggerListItem(reference:DisplayObjectContainer, argWidth:Number, argHeight:Number=60)
      {
         super(reference, argWidth, argHeight);
         _bg = new Sprite();
         _bg.graphics.lineStyle(0, 0x000000, 1);
         _bg.graphics.beginFill(0xc4c4c4, .2);
         _bg.graphics.drawRect(0, 0, argWidth, argHeight);
         this.prepareElementAndPosition(_bg, 1, 1, 1, 80);
         _selectCheckBox = new CheckBox();
         _selectCheckBox.label = "";
         this.prepareElementAndPosition(_selectCheckBox, (this.height - _selectCheckBox.height) / 2, NaN, NaN, 25);
         _labelField = new TextField();
         _labelField.mouseEnabled = false;
         _labelField.height = 22;
         _textFormat = new TextFormat();
         _textFormat.size = 16;
         _labelField.setTextFormat(_textFormat);
         this.prepareElementAndPosition(_labelField, (this.height - _labelField.height - 4) / 2 , NaN, 10, _selectCheckBox.width + 30);
         this.addEventListener(MouseEvent.ROLL_OVER, onMouseOver, false, 0, true);
         this.addEventListener(MouseEvent.ROLL_OUT, onMouseOut, false, 0, true);
         _selectCheckBox.addEventListener(MouseEvent.CLICK, onSelectCheckBoxClick, false, 0, true);
      }
      
      private function onSelectCheckBoxClick(event:Event):void 
      {
         var layoutEvent:LayoutEvent = new LayoutEvent(CHECKBOX_CLICK);
         layoutEvent.extra = this;
         dispatchEvent(layoutEvent);
      }
      
      private function onMouseOver(event:Event):void
      {
         _tween = TweenMax.to(this, .1, {colorMatrixFilter:{colorize:0x00ddff, amount:.3}});
      }
      
      private function onMouseOut(event:Event):void 
      {
         if(_tween)
            _tween.reverse(false);
      }
      
      public function set selected(value:Boolean):void 
      {
         _selectCheckBox.selected = value;
      }
      
      public function get selected():Boolean 
      {
         return _selectCheckBox.selected;
      }
      
      public function set label(value:String):void
      {
         _labelField.text = value;
         _labelField.setTextFormat(_textFormat);
      }
      
      public function get label():String 
      {
         return _labelField.text;
      }
   }
}