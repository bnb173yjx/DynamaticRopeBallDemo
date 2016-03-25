//
//  AnimaView.m
//  ropeBallDemo
//
//  Created by 叶杨 on 16/3/25.
//  Copyright © 2016年 叶景天. All rights reserved.
//

#import "AnimaView.h"

@interface AnimaView ()

@property (nonatomic, strong)UIDynamicAnimator *animator;

//卡板的gravity重力行为
@property (nonatomic, strong)UIGravityBehavior *halfViewGravity;

//ballImageView和,两个控制视图的重力行为
@property (nonatomic, strong)UIGravityBehavior *controllViewGravity;

@property (nonatomic, strong)CAShapeLayer *shapeLayer;

//卡板视图view
@property (nonatomic, strong)UIView *halfView;

@property (nonatomic, strong)UIImageView *ballImageView;

@property (nonatomic, strong)UIView *upControllView;

@property (nonatomic, strong)UIView *downControllView;


@property (nonatomic, strong)UIView *middleView;
@end




@implementation AnimaView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubView];
    }
    return self;
}

- (void)loadSubView
{
    //初始化卡板
    self.halfView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height / 2)];
    self.halfView.alpha = 0.5;
    self.halfView.backgroundColor = [[UIColor alloc]initWithRed:0 green:0.5 blue:1 alpha:0.5];
    [self addSubview:self.halfView];
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]init];
    [pan addTarget:self action:@selector(panAction:)];
    [self.halfView addGestureRecognizer:pan];
    
    //初始化排球图片
    self.ballImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.bounds.size.width / 2) - 30, self.bounds.size.height / 1.5, 60, 60)];
    self.ballImageView.image = [UIImage imageNamed:@"ball.png"];
    [self addSubview:self.ballImageView];
    //为图片添加阴影;
    self.ballImageView.layer.cornerRadius = self.ballImageView.bounds.size.height / 2;
    self.ballImageView.clipsToBounds = YES;
    [self.ballImageView.layer setShadowOffset:CGSizeMake(-4, 4)];
    [self.ballImageView.layer setShadowOpacity:0.5];
    [self.ballImageView.layer setShadowRadius:5.0];
    [self.ballImageView.layer setShadowColor:[UIColor grayColor].CGColor];
    [self.ballImageView.layer setMasksToBounds:NO];
    
    //初始化中间控制试图
    self.middleView = [[UIView alloc]initWithFrame:CGRectMake(self.ballImageView.center.x - 15, 200, 30, 30)];
    [self.middleView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.middleView];
    
    //调整中间控制试图的位置,让它处于小球和卡板view的中间偏下的位置
    [self.middleView setCenter:CGPointMake(self.middleView.center.x, (self.ballImageView.center.y-self.halfView.center.y)+15)];
    
    
    //初始化顶部控制试图
    self.upControllView = [[UIView alloc] initWithFrame:CGRectMake(self.ballImageView.center.x - 15, 200, 30, 30)];
    [self.upControllView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.upControllView];
    //调整self.upControllView的位置
    [self.upControllView setCenter:CGPointMake(self.upControllView.center.x, (self.middleView.center.y - self.halfView.center.y) + self.halfView.center.y/2)];
    
    
    //初始化下边的控制试图
    self.downControllView = [[UIView alloc]initWithFrame:CGRectMake(self.ballImageView.center.x - 15, 200, 30, 30)];
    [self.downControllView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.downControllView];
    [self.downControllView setCenter:CGPointMake(self.downControllView.center.x, (self.middleView.center.y - self.halfView.center.y) + self.halfView.center.y*1.5)];
    [self setUpBehavior];
}

- (void)setUpBehavior
{
    self.animator = [[UIDynamicAnimator alloc]initWithReferenceView:self];
    //为卡板添加重力行为
    self.halfViewGravity = [[UIGravityBehavior alloc]initWithItems:@[self.halfView]];
    [self.animator addBehavior:self.halfViewGravity];
    
    //为上边和下边的控制试图添加重力行为
    self.controllViewGravity = [[UIGravityBehavior alloc]initWithItems:@[self.ballImageView,self.upControllView,self.downControllView]];
    
    __weak AnimaView *weakSelf = self;
    
    //为controllViewGravity赋值,绳子的贝塞尔曲线,将在此处绘制,每当更显animator得时候,将会重新走这个Block方法
    self.controllViewGravity.action = ^{
        UIBezierPath *path=[[UIBezierPath alloc] init];
        [path moveToPoint:weakSelf.halfView.center];
        
        //绘制绳子的贝塞尔曲线,从卡板的center到小球的center,控制点为上下两个控制视图的view.center
        [path addCurveToPoint:weakSelf.ballImageView.center controlPoint1:weakSelf.upControllView.center controlPoint2:weakSelf.downControllView.center];
        
        if (!weakSelf.shapeLayer) {
            weakSelf.shapeLayer = [[CAShapeLayer alloc] init];
            weakSelf.shapeLayer.fillColor = [UIColor clearColor].CGColor;
            weakSelf.shapeLayer.strokeColor = [UIColor colorWithRed:224.0/255.0 green:0.0/255.0 blue:35.0/255.0 alpha:1.0].CGColor;
            weakSelf.shapeLayer.lineWidth = 5.0;
            
            //Shadow
            [weakSelf.shapeLayer setShadowOffset:CGSizeMake(-1, 2)];
            [weakSelf.shapeLayer setShadowOpacity:0.5];
            [weakSelf.shapeLayer setShadowRadius:5.0];
            [weakSelf.shapeLayer setShadowColor:[UIColor blackColor].CGColor];
            [weakSelf.shapeLayer setMasksToBounds:NO];
            
            [weakSelf.layer insertSublayer:weakSelf.shapeLayer below:weakSelf.ballImageView.layer];
        }
        weakSelf.shapeLayer.path=path.CGPath;

    };
    
    [self.animator addBehavior:self.controllViewGravity];
    //先为卡片添加撞击行为,以self.bounds的一般作为边界
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[self.halfView]];
    [collision addBoundaryWithIdentifier:@"Left" fromPoint:CGPointMake(-1, 0) toPoint:CGPointMake(-1, [[UIScreen mainScreen] bounds].size.height)];
    [collision addBoundaryWithIdentifier:@"Right" fromPoint:CGPointMake([[UIScreen mainScreen] bounds].size.width+1,0) toPoint:CGPointMake([[UIScreen mainScreen] bounds].size.width+1, [[UIScreen mainScreen] bounds].size.height)];
    [collision addBoundaryWithIdentifier:@"Middle" fromPoint:CGPointMake(0, [[UIScreen mainScreen] bounds].size.height/2) toPoint:CGPointMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height/2)];
    [_animator addBehavior:collision];
    
    
    //最后一步,也是最关键的一步,就是为卡片view上下两个控制试图,和最下面的一个ballImageView添加,粘性行为
    //记住这里的哥哥attach设置锚点的偏移量要注意,只有锚点的偏移量设置得到好,才能够使绳子跳动起来
    UIAttachmentBehavior *attach1 =  [[UIAttachmentBehavior alloc]initWithItem:self.halfView offsetFromCenter:UIOffsetMake(1, 1) attachedToItem:self.upControllView offsetFromCenter:UIOffsetMake(0, 0)];
    [_animator addBehavior:attach1];
    UIAttachmentBehavior *attach2 = [[UIAttachmentBehavior alloc]initWithItem:self.upControllView offsetFromCenter:UIOffsetMake(0, 0) attachedToItem:self.downControllView offsetFromCenter:UIOffsetMake(0, 0)];
    [_animator addBehavior:attach2];
    
    UIAttachmentBehavior *attach3=[[UIAttachmentBehavior alloc] initWithItem:self.downControllView offsetFromCenter:UIOffsetMake(0, 0) attachedToItem:self.ballImageView offsetFromCenter:UIOffsetMake(0, -_ballImageView.bounds.size.height/2)];
    [_animator addBehavior:attach3];
    
    //最后还要给卡板和小球还有各个控制视图加一个框架.
    UIDynamicItemBehavior *PanItem=[[UIDynamicItemBehavior alloc] initWithItems:@[self.halfView,self.upControllView,self.downControllView,self.ballImageView]];
    PanItem.elasticity = 0.5;
 
    [_animator addBehavior:PanItem];
}


- (void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint translation = [pan translationInView:pan.view];
    //
    if (!(pan.view.center.y + translation.y>(self.bounds.size.height/2)-(pan.view.bounds.size.height/2))) {
        pan.view.center=CGPointMake(pan.view.center.x, pan.view.center.y+ translation.y);
        
        
        [pan setTranslation:CGPointMake(0, 0) inView:pan.view];
    }
    
    if (pan.state==UIGestureRecognizerStateBegan) {
        [self.animator removeBehavior:self.halfViewGravity];
        //        [_animator removeBehavior:_viewsGravity];
    }
    else if (pan.state==UIGestureRecognizerStateChanged){
        
    }
    else if (pan.state==UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled || pan
             .state == UIGestureRecognizerStateFailed
             ) {
        //        self.ballImageView.center = CGPointMake(70, 100);
        
        [self.animator addBehavior:self.halfViewGravity];
        
    }
    
    //通过这个方法可以让animator重新更新它所有的动力行为
    [_animator updateItemUsingCurrentState:pan.view];
}


@end
