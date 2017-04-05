//
//  ViewController.swift
//  Swift2048
//
//  Created by chen on 2017/3/31.
//  Copyright © 2017年 chenly. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    var playView:UIView = UIView(frame: CGRect.init(x: 0, y: 100, width: 375, height: 375));
    var manager : SquareManager!;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(playView);
        playView.backgroundColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1);
        playView.layer.borderColor = UIColor.red.cgColor;
        playView.layer.borderWidth = 1;
        playView.isUserInteractionEnabled = true;
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)));
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)));
        let swipeTop:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)));
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)));
        
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left;
        swipeRight.direction = UISwipeGestureRecognizerDirection.right;
        swipeTop.direction = UISwipeGestureRecognizerDirection.up;
        swipeDown.direction = UISwipeGestureRecognizerDirection.down;
        
        playView.addGestureRecognizer(swipeLeft);
        playView.addGestureRecognizer(swipeRight);
        playView.addGestureRecognizer(swipeTop);
        playView.addGestureRecognizer(swipeDown);
        
        
        // manager
        self.manager = SquareManager(playView: &playView);
        self.manager.beginPlay();
        
    }
    
    func swipeAction(swipe:UISwipeGestureRecognizer)
    {
        self.manager.swipePlayView(direction: swipe.direction);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class SquareManager{
    
    let playView : UIView;
    let squareSize:CGSize;
    var squares:Array<Square> = Array();
    let row:Int = 5;
    
    var win:Bool = true{
        willSet{
            if(!newValue){
                let alert = UIAlertController(title: "结束", message: "没空间了", preferredStyle: UIAlertControllerStyle.alert);
                alert.addAction(UIAlertAction(title: "关闭", style: UIAlertActionStyle.cancel, handler: nil));
                UIApplication.shared.keyWindow!.rootViewController!.present(alert, animated: true, completion: nil);
            }
            
        }
    
    }
    
    init(playView:inout UIView) {
        self.playView = playView;
        let width = playView.frame.size.width / CGFloat.init(row);
        self.squareSize = CGSize(width:width , height: width)
        
    }
    
    func randomIndexInFree() ->(Int)
    {
        var rand : Int = 0;
        var isHave : Bool = true;
        var count = 0;
        
        while (isHave && count < 100) {
            
            rand = Int(arc4random()) % ((row * row) - 1);
            
            isHave = false;
            
            for square in squares {
                if (square.index == rand) {
                    isHave = true;
                }
            }
            
            if !isHave {
                
                return rand;
                
            }
            
            count += count;
        }
 
        return -1;
    }
    
    //initalize view
    func beginPlay() -> Void {
        
        self .addSquareToPayView();
    
    }
    
    
    
    //createSquare
    func createSquare() -> Square? {
        
        let rundomIndex = self.randomIndexInFree();
        
        if rundomIndex < 0 {
            self.win = false;
            
            return nil;
            
        }
        
        let pointX:CGFloat = CGFloat.init(rundomIndex % row)  * squareSize.width;
        let pointY:CGFloat = CGFloat.init(rundomIndex / row) * squareSize.height;
        let frame = CGRect(x: pointX, y: pointY, width: squareSize.width, height: squareSize.height);
        
        //print(rundomIndex,NSStringFromCGRect(frame));
        
        let square = Square.init(frame: frame, index: rundomIndex);
        return square;
        
    }
    
    //addSquare
    func addSquareToPayView() ->Void{
        
        
        guard let square = self .createSquare() else {
            return;
        }
        self.squares.append(square);
        self.playView.addSubview(square);
        square.alpha = 0;
        
        UIView.animate(withDuration: 0.1, delay: 0.3, options: UIViewAnimationOptions.showHideTransitionViews, animations: {
            square.alpha = 1;
        }, completion: nil);

    }
    
    
    
    //move
    func swipePlayView(direction:UISwipeGestureRecognizerDirection) -> Void {
        
        //移动方块
        //self.win = false;
        
        self.rearrangeSquares(direction: direction);
        
        switch direction {
        case UISwipeGestureRecognizerDirection.up:
            print("up");
            
            for square in squares {
                let count = square.index / 5;
                for _ in 0 ..<  count{
                    //print(index);
                    self.moveSquare(square: square, direction: UISwipeGestureRecognizerDirection.up);
                }
            }
            
            
        case UISwipeGestureRecognizerDirection.down:
            print("down");
            for square in squares {
                let count = (row - 1) - square.index / 5;
                for _ in 0 ..<  count{
                    //print(index);
                    self.moveSquare(square: square, direction: UISwipeGestureRecognizerDirection.down);
                }
            }
            
        case UISwipeGestureRecognizerDirection.left:
            print("left");
            for square in squares {
                let count = square.index % row;
                for _ in 0 ..<  count{
                    //print(index);
                    self.moveSquare(square: square, direction: UISwipeGestureRecognizerDirection.left);
                }
            }
        
        case UISwipeGestureRecognizerDirection.right:
            print("right");
            for square in squares {
                let count = row - 1 - square.index % row;
                for _ in 0 ..<  count{
                    //print(index);
                    self.moveSquare(square: square, direction: UISwipeGestureRecognizerDirection.right);
                }
            }
            
        default:
            print("default");
        
        }
        
        
        //添加新方块
        self.addSquareToPayView();
        
        
        for s in squares {
            print(s.textValue,s.index);
        }
        
    }
    
    func moveSquare(square:Square,direction:UISwipeGestureRecognizerDirection) -> Void{
        var frame:CGRect = square.frame;
        var targetIndex:Int = 0;
        
        switch direction {
        case UISwipeGestureRecognizerDirection.up:
            targetIndex = square.index - 5;
            frame.origin.y -= frame.size.height;
            
        case UISwipeGestureRecognizerDirection.down:
            targetIndex = square.index + 5;
            frame.origin.y += frame.size.height;
            
        case UISwipeGestureRecognizerDirection.left:
            targetIndex = square.index - 1;
            frame.origin.x -= frame.size.width;
        case UISwipeGestureRecognizerDirection.right:
            targetIndex = square.index + 1;
            frame.origin.x += frame.size.width;
            
            
            
        default:
            print("aa");
        }
        
        
        
        //
        if (self.isHaveObstacle(index: targetIndex)) {
            //尝试合并
            let target = self.findSquareWith(squareIndex: targetIndex)!;
            if (square.textValue == target .textValue) {
                //value change
                square.textValue *= 2;
                //location change
                
                square.index = targetIndex;
                let targetFrame:CGRect = target.frame;
                
                target.removeFromSuperview();
                squares.remove(at: squares.index(of: target)!);
                
                
                
                UIView.animate(withDuration: 0.3, animations: { 
                     square.frame = targetFrame;
                });
                
            }
            
            
            
        }else
        {
            //移动
            square.index = targetIndex;
            //print(targetIndex);
            UIView.animate(withDuration: 0.3, animations: {
                square.frame = frame;
            }) ;
            
        }
    }
    
    //判断是否存在障碍
    func isHaveObstacle(index : Int) ->Bool{
        
        for square in squares {
            if square.index == index {
                return true;
            }
        }
        
        return false;
    }
    
    
    //Merge
    func mergeSquare(source:Square,target:Square) -> Void {
        
        if (source.textValue == target.textValue) {
            //value change
            source.textValue *= 2;
            
            
            //location change
            UIView.animate(withDuration: 0.3, animations: {
                source.frame = target.frame;
            }) ;
            
            //target remove
            target.removeFromSuperview();
        }
        
        
        
    }
    
    //win or lose
    
    
    //find
    func findSquareWith(squareIndex:Int) -> Square?
    {
        
        for square in squares {
            if square.index == squareIndex {
                return square;
            }
        }
        
        
        return nil;
    }
    
    
    //按照方向重组
    func rearrangeSquares(direction:UISwipeGestureRecognizerDirection) -> Void{
        
        //var tempArray:Array<Square> = Array.init();
        switch direction {
        case UISwipeGestureRecognizerDirection.up:
            self.squares.sort(by: {$0.index < $1.index});
            
        case UISwipeGestureRecognizerDirection.down:
            self.squares.sort(by: {$0.index > $1.index});
            
            
        case UISwipeGestureRecognizerDirection.left:
            self.squares.sort(by: {$0.index < $1.index});
            let col = row;
            var tempArray:Array<Square> = Array();
            
            for c in 0 ..< col {
                for r in 0 ..< row {
                    
                    if let square = self.findSquareWith(squareIndex: r * 5 + c) {
                        tempArray.append(square);
                    }
                }
            }
            self.squares.removeAll();
            self.squares.append(contentsOf: tempArray);
            
            
            
        case UISwipeGestureRecognizerDirection.right:
            self.squares.sort(by: {$0.index > $1.index});
            let col = row;
            var tempArray:Array<Square> = Array();
            
            for c in stride(from: col - 1, through: 0, by: -1) {
                for r in stride(from: row - 1, through: 0, by: -1){
                    
                    if let square = self.findSquareWith(squareIndex: r * row + c) {
                        tempArray.append(square);
                    }
                    
                }
            }
            self.squares.removeAll();
            self.squares.append(contentsOf: tempArray);
            

            
        default:
            print("a");
        }
        
    
    }
    
    
}


//颜色

class Square: UIView {
    
    enum SquareColorValue : Int {
        case white = 2
        case red = 4
        case blue = 8
        case cyan = 16
        case yellow = 32
        case magenta = 64
        case orange = 128
        case purple = 256
        case brown = 512
        case gray = 1024
        case black = 2048
    }
    var valueLable:UILabel;
    var index:Int = 0;
    var textValue:Int = 2 {
        willSet{
            valueLable.text = "\(newValue)";
            
            switch newValue {
            case 2:
                
                    self.valueLable.backgroundColor = UIColor.lightGray;
                
            case 4:
                
                    self.valueLable.backgroundColor = UIColor.red;
                
            case 8:
                
                    self.valueLable.backgroundColor = UIColor.blue;
                
            case 16:
                
                    self.valueLable.backgroundColor = UIColor.cyan;
                
            case 32:
                
                    self.valueLable.backgroundColor = UIColor.yellow;
                
            case 64:
                
                    self.valueLable.backgroundColor = UIColor.magenta;
                
            case 128:
                
                    self.valueLable.backgroundColor = UIColor.orange;
                
            case 256:
                
                    self.valueLable.backgroundColor = UIColor.purple;
                
            case 512:
                
                    self.valueLable.backgroundColor = UIColor.brown;
                
            case 1024:
                
                    self.valueLable.backgroundColor = UIColor.gray;
                
            case 2048:
            
                    self.valueLable.backgroundColor = UIColor.black;
                
            default:
                self.valueLable.backgroundColor = UIColor.black;

            }
        }
    
    }
    
    init(frame: CGRect,index:Int) {
        let  labelFrame = CGRect.init(x: 0, y: 0, width: frame.size.width * 0.8, height: frame.size.width * 0.8);
        self.valueLable = UILabel.init(frame: labelFrame);
        self.index = index;
        
        super.init(frame: frame);
        self.backgroundColor = UIColor.gray;
        
        self.valueLable.text = String.init(textValue);
        self.valueLable.textAlignment = NSTextAlignment.center;
        self.valueLable.font = UIFont.systemFont(ofSize: 30, weight: 2);
        self.valueLable.textColor = UIColor.white;
        self.valueLable.backgroundColor = UIColor.lightGray;
        self.valueLable.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2);
        self.valueLable.layer.cornerRadius = 10;
        self.textValue = 2;
        self.addSubview(self.valueLable);
        
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



