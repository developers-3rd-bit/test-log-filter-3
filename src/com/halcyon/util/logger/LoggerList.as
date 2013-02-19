package com.halcyon.util.logger
{
   import com.halcyon.layout.common.HalcyonScrollableVGroup;
   import com.halcyon.layout.common.LayoutEvent;
   
   public class LoggerList extends HalcyonScrollableVGroup
   {
      private var _allLoggers:Array;
      private var _selectedLoggers:Array;
      private var _totalWidth:Number;
      private var _allListItems:Array;
      
      public function LoggerList(argWidth:Number=15, argHeight:Number=15)
      {
         super(argWidth, argHeight, false);
         _totalWidth = argWidth + 60;
         _allLoggers = new Array();
         _selectedLoggers = new Array();
         _allListItems = new Array();
         this.verticalGap = 0;
      }
      
      public function set dataProvider(value:Array):void 
      {
         _allLoggers.length = 0;
         _selectedLoggers.length = 0;
         if (value)
         {
            value.sort(Array.CASEINSENSITIVE);
         }
         addItems(value, true);   
      }
      
      private function addItems(items:Array, recreateListItems:Boolean = false):void
      {
         if(this.numChildren > 0)
         {
            this.removeChildren(0, this.numChildren - 1);
         }
         
         if(items == null) return;
         
         var itemsLength:int = items.length;
         
         if(recreateListItems) 
         {
            _allListItems.length = 0;
            for(var i:int=0;i<itemsLength;i++)
            {
               var _listItem:LoggerListItem = new LoggerListItem(this, _totalWidth, 40);
               _listItem.label = items[i];
               _listItem.addEventListener(LoggerListItem.CHECKBOX_CLICK, onSelectCheckBoxClick, false, 0, true);
               this.addChild(_listItem);
               _allListItems.push(_listItem);
            }
            _allLoggers = items;   
         }
         else
         {
            for(var j:int=0;j<itemsLength;j++)
            {
               this.addChild(items[j]);
            }
         }
         this.refresh();
      }
      
      private function onSelectCheckBoxClick(layoutEvent:LayoutEvent):void
      {
         var _listItem:LoggerListItem = layoutEvent.extra as LoggerListItem;
         if(_listItem.selected)
            _selectedLoggers.push(_listItem.label);
         else 
         {
            var selectedLoggersLength:int = _selectedLoggers.length;
            for(var i:int=0;i<selectedLoggersLength;i++) 
            {
               if(_selectedLoggers[i] != _listItem.label) continue;
               _selectedLoggers.splice(i, 1);
               break;
            }
         }
      }
      
      public function selectOrUnselectAll(value:Boolean):void 
      {
         _selectedLoggers.length = 0;
         for(var i:int=0;i<this.numChildren;i++) 
         {
            var _listItem:LoggerListItem = this.getChildAt(i) as LoggerListItem;
            if(_listItem == null) continue;
            _listItem.selected = value;
            if(value) _selectedLoggers.push(_listItem.label);
         }
      }
      
      public function get dataProvider():Array 
      {
         return _allLoggers;
      }
      
      public function get selectedLoggers():Array 
      {
         return _selectedLoggers;
      }
      
      public function set selectedLoggers(value:Array):void 
      {
         _selectedLoggers.length = 0;
         if(value == null) return;
         var valueLength:int = value.length;
         for(var i:int=0;i<valueLength;i++) 
         {
            for(var j:int=0;j<this.numChildren;j++)
            {
               var _listItem:LoggerListItem = this.getChildAt(j) as LoggerListItem;
               if(_listItem == null) continue;
               if(_listItem.label != value[i]) continue;
               _listItem.selected = true;
               _selectedLoggers.push(_listItem.label);
               break;
            }
         }
      }
   }
}