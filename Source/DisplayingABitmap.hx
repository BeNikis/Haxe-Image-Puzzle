package;


import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.text.TextField;

import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.Assets;
import nme.Lib;




/**
 * @author Joshua Granick
 */
class DisplayingABitmap extends Sprite {
	
	
	private var logo:Bitmap;
	private var sprites:Array<BitmapData>;
	private var index:Int;
	private var c:PuzzleState;
	
	public function new (source:BitmapData ,count:PuzzleState ,sprite_num : Int ,start_index:Int, xx:Float,yy:Float) {
		sprites=new Array<BitmapData>();
		super ();
		index=if (start_index>sprite_num) 0 else start_index;
		sprites[0]=source.clone();
		
		x=xx;
		y=yy;
		c=count;
		//decrease the PuzzleState if we are at the original image
		if (start_index==0) c.c--;
		
		for (i in 1...sprite_num) {
			sprites[i]=(new BitmapData(source.width,source.height));
		}
		
		construct();
		addEventListener (MouseEvent.MOUSE_OVER, over);
		
		//protection against right click cheating. This requires swf version 11.2
		 //antiHax);
		
		
	}
	
	

	function over(e:MouseEvent) {
			c.steps++;

			var oindex=index;
			index=(if (index-1==-1) sprites.length-1 else index-1);
			logo.bitmapData=sprites[index];
			
			if (oindex == 0) 
				c.c++;
			else if (index == 0) c.c--;

			if (c.c==0) c.win();
			
			
		}
	

	
	private function construct () {
		
		/*
		parent.align = StageAlign.TOP_LEFT;
		parent.scaleMode = StageScaleMode.NO_SCALE;
		*/

		for (i in 1...sprites.length) {
			
			shuffle(i,i,new Rectangle(0,0,sprites[0].width,sprites[0].height));
		}	
		logo = new Bitmap (sprites[index]);
		

		//resize ();
		addChild (logo);
		
		//stage.addEventListener (Event.RESIZE, stage_onResize);
		
	}
	
	//target - the sprite being created
	//level  - the nest level of the shuffle
	
	private function permute<T>(list :Array<T>) :Array<T> {
		var result=list.copy();
		for (i in 0...list.length) {
			var rind = Std.random(result.length);
			var t = result[rind];
			result[rind]=result[result.length-i-1];
			result[result.length-i-1]=t;
		}
		
		return result;
	}

	private function shuffle(target:Int,level:Int,rect:Rectangle) {

			if (level == 1) {
				//helper functions for array equality
				/*
				var eq :Array<T> -> Int -> T -> Bool = function (ar,index,e) {return ar[index]==e;};
				var arr_eq= function (arr:Array<T>,arr2) {return Lambda.fold(Lambda.mapi(arr,callback(eq,arr2)),(function (a,b) {return a&&b;}),true);};
				*/
				
				//randomization so we don't mirror along an axis
				var points : Array<Point> = new Array<Point>();
				var indic : Array<Int> = new Array<Int>();
				points.push(new Point(rect.x+rect.width/2,rect.y+rect.height/2));
				points.push(new Point(rect.x,rect.y+rect.height/2));
				points.push(new Point(rect.x+rect.width/2,rect.y));
				points.push(new Point(rect.x,rect.y));
				//*
				do {
					indic=permute([0,1,2,3]);
				} while (indic.toString()==[0,1,2,3].toString() || indic.toString()==[3,2,1,0].toString());

				
			//top left
				sprites[target].copyPixels(sprites[target-1],
						new Rectangle(rect.x,rect.y,rect.width/2,rect.height/2),
						points[indic[0]]);
		
			//top right
				sprites[target].copyPixels(sprites[target-1],
						new Rectangle(rect.x+rect.width/2,rect.y,rect.width/2,rect.height/2),
						points[indic[1]]);

			//bottom left
				sprites[target].copyPixels(sprites[target-1],
						new Rectangle(rect.x,rect.y+rect.height/2,rect.width/2,rect.height/2),
						points[indic[2]]);

			//bottom right
				sprites[target].copyPixels(sprites[target-1],
						new Rectangle(rect.x+rect.width/2,rect.y+rect.height/2,rect.width/2,rect.height/2),
						points[indic[3]]);

			}
			else {
				shuffle(target,level-1,new Rectangle(rect.x,rect.y,			rect.width/2,rect.height/2));
				shuffle(target,level-1,new Rectangle(rect.x+rect.width/2,rect.y,		rect.width/2,rect.height/2));
				shuffle(target,level-1,new Rectangle(rect.x,rect.y+rect.height/2,	rect.width/2,rect.height/2));
				shuffle(target,level-1,new Rectangle(rect.x+rect.width/2,rect.y+rect.height/2,rect.width/2,rect.height/2));

			}
	}
	
	private function resize () {
		/*
		logo.x = (stage.stageWidth - x) / 2;
		logo.y = (stage.stageHeight - logo.height) / 2;
		*/
	}
	
	
	
	
	
	// Event Handlers
	
	
	
	
	private function stage_onResize (event:Event):Void {
		
		resize ();
		
	}
	
	
	private function this_onAddedToStage (event:Event):Void {
		
		construct ();
		
	}
	
	
	
	
	// Entry point
	
	
	
	
	public static function main () {
		
		
		//Lib.current.addChild (new DisplayingABitmap(Assets.getBitmapData ("assets/nme.png"),new PuzzleState(0),6,0) );
		Lib.current.addChild (new GridImage(Assets.getBitmapData ("assets/nme.png")) );
		Lib.current.getChildAt(0).addEventListener (MouseEvent.RIGHT_MOUSE_DOWN,function(e:Event) {});
	}
	
	
}

//For keeping track of cells shopwing the undistorted image
//initialize with the number of cells
class PuzzleState {
	public var c:Int;
	public var prev_cell:Array<Int>;

	public var win:Void -> Void;
	
	//dimensions of the source image
	public var width:Int;
	public var height:Int;

	//number of the players' steps
	public var steps:Int; 
	
	public function new(start:Int,w:Int,h:Int) {
		c=start;
		width=w;
		height=h;
		steps=0;
	}
}


class GridImage extends Sprite{
	
	var state : PuzzleState;

	//to be implemented in the controller
	//var puzzle:MockImage

	//mock 
	public function new(source:BitmapData) {
			super();
			var mod = 4;
			state=new PuzzleState(mod*mod,source.width,source.height);
			

			state.win=function() {
					var winText = new TextField();
					winText.text = "You won! " + state.steps;
					winText.x=source.width/2;
					winText.y=source.height+100;
					this.addChild(winText);

				};
			
			var remx=source.width % mod;
			var remy=source.height % mod;

			var rec = new Rectangle(0 , 0 ,source.width/mod , source.height/mod);
			var cellData=new BitmapData(Math.round(source.width/mod) ,Math.round(source.height/mod));
			for (y in 0...mod) {
				
				//In case the number of rows doesn't divide the height of the source image
				if (y==mod-1) {
					rec.height+=remy;
					rec.y-=remy;
				}
				
				for (x in 0...mod) {
					
					//In case the number of columns doesn't divide the width of the source image
					if (x==mod-1) { 
						rec.width+=remx;
						rec.x-=remx;
					}
					

					cellData.copyPixels(source,rec,new Point(0,0));
					addChild(new DisplayingABitmap(cellData,state,mod,Std.random(mod),rec.x,rec.y));
					rec.x+=source.width/mod;
					
				}

				
				
				rec.x=0;
				rec.y+=source.height/mod;
				
			}
			

	}
}