package com.halcyon.util.logger
{
   import com.halcyon.layout.common.HalcyonButton;
   import com.halcyon.layout.common.HalcyonCanvas;
   import com.halcyon.layout.common.HalcyonLabel;
   import com.soma.ui.layouts.CanvasUI;
   
   import fl.controls.Button;
   
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class LoggerCanvas extends HalcyonCanvas
   {
      public static const CLOSE_BTN_CLICK:String = "closeBtnClick";
      
      private var _list:LoggerList;
      private var _titleLabel:HalcyonLabel;
      private var _selectAllBtn:Button;
      private var _resetBtn:Button;
      private var _closeBtn:HalcyonButton;
      private var _isAllItemsSelected:Boolean = false;
      private const PADDING:Number = 5;
      private const LIST_TO_BORDER:Number = 50;
      
      public function LoggerCanvas(reference:DisplayObjectContainer, argWidth:Number=15, argHeight:Number=15)
      {
         super(reference, argWidth, argHeight);
         
         this.backgroundColor = 0xffffff;
         this.backgroundAlpha = 1;
         
         // title bg
         var bg:CanvasUI = new CanvasUI(this);
         bg.backgroundColor = 0xcccccc;
         bg.backgroundAlpha = .6;
         bg.height = 45;
         this.prepareElementAndPosition(bg, 0, NaN, 0, 0);
         bg.addEventListener(MouseEvent.MOUSE_DOWN, startDraging);
         bg.addEventListener(MouseEvent.MOUSE_UP, stopDraging);
         
         // title
         _titleLabel = new HalcyonLabel("Log filter:", 22);
         _titleLabel.fontColor = 0x777777;
         this.prepareElementAndPosition(_titleLabel, PADDING, NaN, 30, NaN);
         
         // close button
         _closeBtn = new HalcyonButton(McCloseButton);
         _closeBtn.height = 32;
         _closeBtn.width = 32;
         _closeBtn.addEventListener(MouseEvent.CLICK, onCloseBtnClick, false, 0, true);
         this.prepareElementAndPosition(_closeBtn.content, 20, NaN, NaN, 35);
         
         // select button
         _selectAllBtn = new Button();
         _selectAllBtn.label = "Select All";
         _selectAllBtn.useHandCursor = true;
         _selectAllBtn.height = 30;
         _selectAllBtn.width = 75;
         _selectAllBtn.addEventListener(MouseEvent.CLICK, onSelectAllBtnClick, false, 0, true);
         this.prepareElementAndPosition(_selectAllBtn, PADDING, NaN, NaN, _closeBtn.content.width + 65);
         
         // reset button
         _resetBtn = new Button();
         _resetBtn.label = "Reset";
         _resetBtn.useHandCursor = true;
         _resetBtn.height = 30;
         _resetBtn.width = 75;
         _resetBtn.addEventListener(MouseEvent.CLICK, onResetClick, false, 0, true);
         this.prepareElementAndPosition(_resetBtn, PADDING, NaN, NaN, _closeBtn.content.width + _selectAllBtn.width + 80);
         
         // list area
         _list = new LoggerList(argWidth - (LIST_TO_BORDER * 2), argHeight - 90);
         this.prepareElementAndPosition(_list, 60, NaN, LIST_TO_BORDER, NaN);
      }
      
      private function startDraging(e:Event):void{
         this.startDrag();
      }
      
      private function stopDraging(e:Event):void{
         this.stopDrag();
      }	
      
      private function onCloseBtnClick(event:Event):void 
      {
         dispatchEvent(new Event(CLOSE_BTN_CLICK));
      }
      
      private function onSelectAllBtnClick(event:Event):void 
      {
         _list.selectOrUnselectAll(true);
      }
      
      private function onResetClick(event:Event):void 
      {
         _list.selectOrUnselectAll(false);
      }
      
      public function get allLoggers():Array
      {
         return _list.dataProvider;
      }
      
      public function set allLoggers(value:Array):void
      {
         _list.dataProvider = value;
      }
      
      public function get selectedLoggers():Array
      {
         return _list.selectedLoggers;
      }
      
      public function set selectedLoggers(value:Array):void
      {
         _list.selectedLoggers = value;
      }
   }
}