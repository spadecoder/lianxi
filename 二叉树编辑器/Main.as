﻿package  {
	
	import Box2D.Collision.b2DynamicTreeNode;
	import com.adobe.images.PNGEncoder;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	
	public class Main extends MovieClip {
		
		private var con:Sprite;
		public var tf:TextField;
		public var helpTf:TextField;
		public var alert:TextField;
		public function Main() {
			// constructor code
			con = new Sprite();
			addChild(con);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			tf.visible = false;
			// helpTf.visible = false;
			alert.visible = false;
			alert.mouseEnabled = false;
			travel();
		}
		
		private function mouseWheelHandler(e:MouseEvent):void 
		{
			if (e.delta > 0){
				// 放大
				con.scaleX += 0.1;
				con.scaleY += 0.1;
			} else {
				if(con.scaleX > 0.1){
					con.scaleX -= 0.1;
					con.scaleY -= 0.1;
				}
			}
		}
		
		private function keyDownHandler(e:KeyboardEvent):void 
		{
			trace(e.keyCode);
			if (e.ctrlKey && e.keyCode == 78){
				// ctrl+N
				var node:Node = new Node();
				con.addChild(node);
				node.x = 500 + (Math.random() - 0.5) * 100;
				node.y = 300 + (Math.random() - 0.5) * 100;
				drag(node);
			} else if (e.ctrlKey && e.keyCode == 83){
				// ctrl+s
				// 保存
				saveBmp();
			} else if (e.keyCode == 46){
				// delete
				// trace(stage.focus);
				if (e.ctrlKey){
					// 删除当前节点及所有子节点
					if (stage.focus is Node){
						removeNode(stage.focus as Node, true);
						updateLR();
					}
				} else {
					// 删除一个节点
					if (stage.focus is Node){
						removeNode(stage.focus as Node, false);
						updateLR();
					}
				}
			} else if (e.keyCode == 113){
				// f2
				// 遍历结果
				tf.visible = !tf.visible;
				if (tf.visible){
					showResult();
				}
			} else if (e.keyCode == 27){
				// ESC
				// 隐藏遍历结果
				tf.visible = false;
			} else if (e.ctrlKey && e.keyCode == 66){
				// ctrl+b
				// 断开节点
				if (stage.focus is Node){
					breakNode(stage.focus as Node);
					updateLR();
				}
			} else if (e.ctrlKey && e.keyCode == 187){
				// ctrl++
				// 放大
				con.scaleX += 0.1;
				con.scaleY += 0.1;
			} else if (e.ctrlKey && e.keyCode == 189){
				// ctrl+-
				// 缩小
				if(con.scaleX > 0.1){
					con.scaleX -= 0.1;
					con.scaleY -= 0.1;
				}
			} else if (e.ctrlKey && e.keyCode == 48){
				// ctrl+0
				// 1:1
				con.scaleX = 1.0;
				con.scaleY = 1.0;
			} else if (e.keyCode == 112){
				// f1
				// 帮助
				helpTf.visible = !helpTf.visible;
			} else if (e.keyCode == 114){
				// f3
				// 打开
				open();
			} 
			
		}
		
		var f:FileReference = new FileReference();
		private function open():void{
			f.browse([new FileFilter("*.json", "*.json")]);
			f.addEventListener(Event.SELECT, fileSelected);
			f.addEventListener(Event.CANCEL, fileCancel);
		}
		
		private function fileCancel(e:Event):void 
		{
			f.removeEventListener(Event.SELECT, fileSelected);
			f.removeEventListener(Event.CANCEL, fileCancel);
		}
		
		private function fileSelected(e:Event):void 
		{
			f.load();
			f.addEventListener(Event.COMPLETE, fileLoaded);
		}
		
		private function fileLoaded(e):void{
			f.removeEventListener(Event.COMPLETE, fileLoaded);
			try{
				var s:String = String(f.data);
				var o:Object = JSON.parse(s);
				trace(s);
				createTreeByJson(o);
			} catch (e:Event){
				trace("error:" + e);
				alert.text = "error:" + e;
				alert.visible = true;
				setTimeout(hideAlert, 3000);
			}
			trace(s);
		}
		
		private function hideAlert():void{
			alert.visible = false;
		}
		
		private function createTreeByJson(o:Object):void{
			con.x = o.x;
			con.y = o.y;
			con.scaleX = o.sx;
			con.scaleY = o.sy;
			var data:Array = o.data;
			var n0:Object;
			for (var i:int = 0; i < data.length; i++){
				n0 = data[i];
				var node:Node = new Node(n0.v, n0.uid);
				n0.node = node;
				if(n0.x || n0.y){
					node.x = n0.x;
					node.y = n0.y;
				}
				con.addChild(node);
				drag(node);
			}
			
			for (var j:int = 0; j < data.length; j++){
				n0 = data[j];
				if (n0.l){
					var lNode:Node = findNode(n0.l);
					n0.node.left = lNode;
					n0.node.circleL.visible = false;
					lNode.parentNode = n0.node;
				}
				if(n0.r){
					var rNode:Node = findNode(n0.r);
					n0.node.right = rNode;
					n0.node.circleR.visible = false;
					rNode.parentNode = n0.node;
				}
			}
			updateLR();
		}
		
		private function findNode(uid:Number):Node{
			for (var i:int = 0; i < con.numChildren; i++){
				var node:Node = con.getChildAt(i) as Node;
				if (node.uid == uid){
					return node;
				}
			}
			return null;
		}
		
		/**
		 * 保存图片
		 */
		private function saveBmp():void{
			if (con.numChildren){
				var rect:Rectangle = con.getBounds(this);
				var bmd:BitmapData = new BitmapData(rect.width, rect.height, true, 0x00000000);
				bmd.draw(con, new Matrix(con.scaleX, 0, 0, con.scaleY, -rect.x, -rect.y));
				var bytes:ByteArray = PNGEncoder.encode(bmd);
				var f:FileReference = new FileReference();
				var t:Number = new Date().getTime();
				f.save(bytes, "binary_tree_" + t + '.png');
				var flag:Boolean = false;
				f.addEventListener(Event.COMPLETE, function(){
					if(flag){
						return;
					}
					flag = true;
					var o:Object = getJson();
					var s:String = JSON.stringify(o, null, 2);
					f.save(s, "binary_tree_data_" + t + ".json");
				});
			}
		}
		
		private function getJson():Object{
			var result:Array = [];
			forEachNode(function (node:Node){
				var o:Object = {
					v: node.getValue(),
					uid: node.uid
				};
				if (node.left){
					o.l = node.left.uid;
				}
				if (node.right){
					o.r = node.right.uid;
				}
				if (isRoot(node)){
					o.x = Math.round(node.x);
					o.y = Math.round(node.y);
				}
				result.push(o);
			});
			return {
				x: Math.round(con.x),
				y: Math.round(con.y),
				sx: con.scaleX,
				sy: con.scaleY,
				data: result
			};
		}
		
		/**
		 * 显示遍历结果
		 */
		private function showResult(){
			tf.text = "-----------\n";
			if (stage.focus is Node){
				var o:Object = getResult(stage.focus as Node);
				appendText(o);
			} else {
				var arr:Array = getResult(null) as Array;
				for (var i:int = 0; i < arr.length; i++ ){
					appendText(arr[i]);
					tf.appendText("\n");
				}
			}
		}
		
		private function appendText(o:Object){
			tf.appendText("前序遍历："+ o.pre.join(',') + '\n');
			tf.appendText("中序遍历："+ o.order.join(',') + '\n');
			tf.appendText("后序遍历："+ o.post.join(',') + '\n');
		}
		
		private function getResult(node:Node):Object{
			var o:Object = {"pre":[], "order": [], "post": []};
			if(node){
				preOrderTreeWalk(node, o.pre);
				inOrderTreeWalk(node, o.order);
				postOrderTreeWalk(node, o.post);
			} else {
				var arr:Array = [];
				forEachRoot(function(node:Node){
					arr.push(getResult(node));
				});
				return arr;
			}
			return o;
		}
		
		private function updateLR(){
			forEachRoot(function(node:Node){
				node.updateMaxLR();
				node.updateLR();
				dragMove(node);
			});
		}
		
		/**
		 * 删除节点
		 * @param	node
		 * @param	digui 是否递归
		 */
		private function removeNode(node:Node, digui:Boolean){
			if(!node){
				return;
			}
			if(digui){
				removeNode(node.left, digui);
				removeNode(node.right, digui);
			}
			breakNode(node);
			breakNode(node.left);
			breakNode(node.right);
			node.destroy();
			con.removeChild(node);
		}
		
		/**
		 * 断开节点和父节点的链接
		 * @param	node
		 */
		private function breakNode(node:Node):void{
			if(!node){
				return;
			}
			if(node.parentNode){
				if (node.parentNode.left == node){
					node.parentNode.left = null;
					node.parentNode.circleL.visible = true;
				} else {
					node.parentNode.right = null;
					node.parentNode.circleR.visible = true;
				}
				node.parentNode = null;
			}
		}
		
		/**
		 * 拖拽节点结束
		 * @param	node
		 */
		private function dragEnd(node:Node):void{
			if(node.parentNode){
				breakNode(node);
			}
			for (var i:int = 0; i < con.numChildren; i++ ){
				var no:Node = con.getChildAt(i) as Node;
				if(no == node){
					continue;
				}
				if (!node.parentNode){
					checkHit(node, no);
				}
				if (!no.parentNode){
					checkHit(no, node);
				}
			}
			updateLR();
		}
		
		/**
		 * 拖拽节点移动
		 * @param	node
		 */
		private function dragMove(node:Node):void{
			if(node.left){
				node.left.x = node.x + node.circleL.x;
				node.left.y = node.y + node.circleL.y;
				dragMove(node.left);
			}
			if(node.right){
				node.right.x = node.x + node.circleR.x;
				node.right.y = node.y + node.circleR.y;
				dragMove(node.right);
			}
		}
		
		/**
		 * 检测节点碰撞
		 * @param	no1
		 * @param	no2
		 */
		private function checkHit(no1:Node, no2:Node):void{
			if (no1.circle.hitTestObject(no2.circleL)){
				no2.circleL.visible = false;
				no2.left = no1;
				no1.parentNode = no2;
				no1.x = no2.x + no2.circleL.x;
				no1.y = no2.y + no2.circleL.y;
				dragMove(no1);
			} else if (no1.circle.hitTestObject(no2.circleR)){
				no2.circleR.visible = false;
				no2.right = no1;
				no1.parentNode = no2;
				no1.x = no2.x + no2.circleR.x;
				no1.y = no2.y + no2.circleR.y;
				dragMove(no1);
			}
		}
		
		/**
		 * 获取根节点
		 * @param	node
		 * @return
		 */
		private function getRoot(node:Node):Node{
			while(node.parentNode){
				node = node.parentNode;
			}
			return node;
		}
		
		/**
		 * 前序遍历
		 * @param	node
		 * @return
		 */
		private function preOrderTreeWalk(node:Node, arr:Array):void{
			if(!node){
				return;
			}
			arr.push(node.getValue());
			preOrderTreeWalk(node.left, arr);
			preOrderTreeWalk(node.right, arr);
		}
		
		/**
		 * 中序遍历
		 * @param	node
		 * @return
		 */
		private function inOrderTreeWalk(node:Node, arr:Array):void{
			if(!node){
				return;
			}
			inOrderTreeWalk(node.left, arr);
			arr.push(node.getValue());
			inOrderTreeWalk(node.right, arr);
		}
		
		/**
		 * 后序遍历
		 * @param	node
		 * @return
		 */
		private function postOrderTreeWalk(node:Node, arr:Array):void{
			if(!node){
				return;
			}
			postOrderTreeWalk(node.left, arr);
			postOrderTreeWalk(node.right, arr);
			arr.push(node.getValue());
		}
		
		private function forEachRoot(callBack:Function):void{
			for (var i:int = 0; i < con.numChildren; i++){
				var node:Node = con.getChildAt(i) as Node;
				if (isRoot(node)){
					callBack(node);
				}
			}
		}
		
		private function forEachNode(callBack:Function):void{
			for (var i:int = 0; i < con.numChildren; i++){
				var node:Node = con.getChildAt(i) as Node;
				callBack(node);
			}
		}
		
		private function isRoot(node:Node):Boolean{
			return node.parentNode == null;
		}
		
		//------------------------------
		private var p:Point = new Point();
		private function travel(){
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);
		}
		
		private function stageMouseDownHandler(e:MouseEvent):void 
		{
			if(e.target is Stage){
				p.x = stage.mouseX;
				p.y = stage.mouseY;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
				stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
				stage.addEventListener(Event.MOUSE_LEAVE, stageMouseUpHandler);
			}
		}
		
		private function stageMouseUpHandler(e:Event):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			stage.removeEventListener(Event.MOUSE_LEAVE, stageMouseUpHandler);
		}
		
		private function stageMouseMoveHandler(e:MouseEvent):void 
		{
			var dx:Number = stage.mouseX - p.x;
			var dy:Number = stage.mouseY - p.y;
			p.x = stage.mouseX;
			p.y = stage.mouseY;
			for (var i:int = 0; i < con.numChildren; i++ ){
				var sp:Node = con.getChildAt(i) as Node;
				sp.x += dx;
				sp.y += dy;
			}
		}
		
		//---------------------------
		private var dragSp:Sprite;
		private function cancelDrag(sp:Sprite):void{
			sp.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		private function drag(sp:Sprite):void{
			sp.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		private function mouseUpHandler(e:Event):void 
		{
			
			dragSp.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
			dragEnd(dragSp as Node);
			dragSp = null;
		}
		
		private function mouseDownHandler(e:MouseEvent):void 
		{
			dragSp = e.currentTarget as Sprite;
			dragSp.startDrag();
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
		}
		
		private function mouseMoveHandler(e:MouseEvent):void 
		{
			dragMove(dragSp as Node);
		}
	}
	
}


/*
keycode 0 =

keycode 1 =
keycode 2 =
keycode 3 =
keycode 4 =
keycode 5 =
keycode 6 =
keycode 7 =
keycode 8 = BackSpace
keycode 9 = Tab
keycode 10 =
keycode 11 =
keycode 12 = Clear
keycode 13 = Enter
keycode 14 =
keycode 15 =
keycode 16 = Shift_L
keycode 17 = Control_L
keycode 18 = Alt_L
keycode 19 = Pause
keycode 20 = Caps_Lock
keycode 21 =
keycode 22 =
keycode 23 =
keycode 24 =
keycode 25 =
keycode 26 =
keycode 27 = Esc Escape
keycode 28 =
keycode 29 =
keycode 30 =
keycode 31 =
keycode 32 = Space
keycode 33 = Page Up
keycode 34 = Page Down
keycode 35 = End
keycode 36 = Home
keycode 37 = Left Arrow
keycode 38 = Up Arrow
keycode 39 = Right Arrow
keycode 40 = Down Arrow
keycode 41 = Select
keycode 42 = Print
keycode 43 = Execute
keycode 44 =
keycode 45 = Insert
keycode 46 = Delete
keycode 47 = Help
keycode 48 = 0 )
keycode 49 = 1 !
keycode 50 = 2 @
keycode 51 = 3 #
keycode 52 = 4 $
keycode 53 = 5 %
keycode 54 = 6 ^
keycode 55 = 7 &
keycode 56 = 8 *
keycode 57 = 9 (
keycode 58 =
keycode 59 =
keycode 60 =
keycode 61 =
keycode 62 =
keycode 63 =
keycode 64 =
keycode 65 = a A
keycode 66 = b B
keycode 67 = c C
keycode 68 = d D
keycode 69 = e E
keycode 70 = f F
keycode 71 = g G
keycode 72 = h H
keycode 73 = i I
keycode 74 = j J
keycode 75 = k K
keycode 76 = l L
keycode 77 = m M
keycode 78 = n N
keycode 79 = o O
keycode 80 = p P
keycode 81 = q Q
keycode 82 = r R
keycode 83 = s S
keycode 84 = t T
keycode 85 = u U
keycode 86 = v V
keycode 87 = w W
keycode 88 = x X
keycode 89 = y Y
keycode 90 = z Z
keycode 91 =
keycode 92 =
keycode 93 =
keycode 94 =
keycode 95 =
keycode 96 = KP_0
keycode 97 = KP_1
keycode 98 = KP_2
keycode 99 = KP_3
keycode 100 = KP_4
keycode 101 = KP_5
keycode 102 = KP_6
keycode 103 = KP_7
keycode 104 = KP_8
keycode 105 = KP_9
keycode 106 = KP_* KP_Multiply
keycode 107 = KP_+ KP_Add
keycode 108 = KP_Enter KP_Separator
keycode 109 = KP_- KP_Subtract
keycode 110 = KP_. KP_Decimal
keycode 111 = KP_/ KP_Divide
keycode 112 = F1
keycode 113 = F2
keycode 114 = F3
keycode 115 = F4
keycode 116 = F5
keycode 117 = F6
keycode 118 = F7
keycode 119 = F8
keycode 120 = F9
keycode 121 = F10
keycode 122 = F11
keycode 123 = F12
keycode 124 = F13
keycode 125 = F14
keycode 126 = F15
keycode 127 = F16
keycode 128 = F17
keycode 129 = F18
keycode 130 = F19
keycode 131 = F20
keycode 132 = F21
keycode 133 = F22
keycode 134 = F23
keycode 135 = F24
keycode 136 = Num_Lock
keycode 137 = Scroll_Lock
keycode 138 =
keycode 139 =
keycode 140 =
keycode 141 =
keycode 142 =
keycode 143 =
keycode 144 =
keycode 145 =
keycode 146 =
keycode 147 =
keycode 148 =
keycode 149 =
keycode 150 =
keycode 151 =
keycode 152 =
keycode 153 =
keycode 154 =
keycode 155 =
keycode 156 =
keycode 157 =
keycode 158 =
keycode 159 =
keycode 160 =
keycode 161 =
keycode 162 =
keycode 163 =
keycode 164 =
keycode 165 =
keycode 166 =
keycode 167 =
keycode 168 =
keycode 169 =
keycode 170 =
keycode 171 =
keycode 172 =
keycode 173 =
keycode 174 =
keycode 175 =
keycode 176 =
keycode 177 =
keycode 178 =
keycode 179 =
keycode 180 =
keycode 181 =
keycode 182 =
keycode 183 =
keycode 184 =
keycode 185 =
keycode 186 =
keycode 187 = =+
keycode 188 = ,<
keycode 189 = -_
keycode 190 = .>
keycode 191 = /?
keycode 192 = `~
keycode 193 =
keycode 194 =
keycode 195 =
keycode 196 =
keycode 197 =
keycode 198 =
keycode 199 =
keycode 200 =
keycode 201 =
keycode 202 =
keycode 203 =
keycode 204 =
keycode 205 =
keycode 206 =
keycode 207 =
keycode 208 =
keycode 209 =
keycode 210 = plusminus hyphen macron
keycode 211 =
keycode 212 = copyright registered
keycode 213 = guillemotleft guillemotright
keycode 214 = masculine ordfeminine
keycode 215 = ae AE
keycode 216 = cent yen
keycode 217 = questiondown exclamdown
keycode 218 = onequarter onehalf threequarters
keycode 219 = [{
keycode 220 = \|
keycode 221 = ]}
keycode 222 = '"

keycode 223 =
keycode 224 =
keycode 225 =
keycode 226 =
keycode 227 = multiply division
keycode 228 = acircumflex Acircumflex
keycode 229 = ecircumflex Ecircumflex
keycode 230 = icircumflex Icircumflex
keycode 231 = ocircumflex Ocircumflex
keycode 232 = ucircumflex Ucircumflex
keycode 233 = ntilde Ntilde
keycode 234 = yacute Yacute
keycode 235 = oslash Ooblique
keycode 236 = aring Aring
keycode 237 = ccedilla Ccedilla
keycode 238 = thorn THORN
keycode 239 = eth ETH
keycode 240 = diaeresis cedilla currency
keycode 241 = agrave Agrave atilde Atilde
keycode 242 = egrave Egrave
keycode 243 = igrave Igrave
keycode 244 = ograve Ograve otilde Otilde
keycode 245 = ugrave Ugrave
keycode 246 = adiaeresis Adiaeresis
keycode 247 = ediaeresis Ediaeresis
keycode 248 = idiaeresis Idiaeresis
keycode 249 = odiaeresis Odiaeresis
keycode 250 = udiaeresis Udiaeresis
keycode 251 = ssharp question backslash
keycode 252 = asciicircum degree
keycode 253 = 3 sterling
keycode 254 = Mode_switch
*/