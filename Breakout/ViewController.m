//
//  ViewController.m
//  Breakout
//
//  Created by Marion Ano on 3/20/14.
//  Copyright (c) 2014 Marion Ano. All rights reserved.
//

#import "ViewController.h"
#import "PaddleView.h"
#import "BallView.h"
#import "BlockView.h"

#define BLOCK_WIDTH_EASY 40
#define BLOCK_HEIGHT_EASY 40
#define NUMBER_ROWS 1

@interface ViewController () 
{
    UIDynamicAnimator *dynamicAnimator;
    UIPushBehavior* pushBehavior;
    UICollisionBehavior *collisionBehavior;
    IBOutlet BallView *ballView;
    IBOutlet PaddleView *paddleView;
    UIDynamicItemBehavior* ballDynamicBehavior;
    UIDynamicItemBehavior* paddleDynamicBehavior;
    UIDynamicItemBehavior* blockDynamicBehavior;
    NSInteger numberOfBlocks;
}

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    [self initializePushBehavior];
    
    [self initializeCollisionBehavior];

    [self inititalizeDynamicBallBehavior];
    
    [self initializeDynamicPaddleBehavior];
    
    [self addBlocksToMainView];
}

#pragma mark - Initialization Methods for Dynamic Behaviors

- (void)inititalizeDynamicBallBehavior
{
    ballDynamicBehavior = [[UIDynamicItemBehavior alloc]initWithItems:@[ballView]];
    ballDynamicBehavior.allowsRotation = NO;
    ballDynamicBehavior.density = 1.0;
    ballDynamicBehavior.elasticity = 1.0;
    ballDynamicBehavior.friction = 0.0;
    ballDynamicBehavior.resistance = 0.0;
    [dynamicAnimator addBehavior:ballDynamicBehavior];
}


- (void)initializeDynamicPaddleBehavior
{
    paddleDynamicBehavior = [[UIDynamicItemBehavior alloc]initWithItems:@[paddleView]];
    paddleDynamicBehavior.allowsRotation = NO;
    paddleDynamicBehavior.density = 1000;
    [dynamicAnimator addBehavior:paddleDynamicBehavior];
}


- (void)initializeCollisionBehavior
{
    collisionBehavior = [[UICollisionBehavior alloc]initWithItems:@[ballView, paddleView]];
    collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    
    //turn reference bounds into a boundary (UIView becomes of reference boundary)
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionDelegate = self;
    [dynamicAnimator addBehavior:collisionBehavior];
}


- (void)initializePushBehavior
{
    pushBehavior = [[UIPushBehavior alloc]initWithItems:@[ballView] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = CGVectorMake(0.5,1.0);//down to right
    pushBehavior.active = YES;
    pushBehavior.magnitude =  0.1;
    [dynamicAnimator addBehavior:pushBehavior];
}


-(void)resetPushBehavior
{
    
    CGVector reversedDirection = CGVectorMake(pushBehavior.pushDirection.dx*-1.0f,pushBehavior.pushDirection.dy*-1.0f);
    pushBehavior = nil;
    pushBehavior = [[UIPushBehavior alloc]initWithItems:@[ballView] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = reversedDirection;
    pushBehavior.active = YES;
    pushBehavior.magnitude =  0.1;
    [dynamicAnimator addBehavior:pushBehavior];
    
}


/*
 * Generate a matrix of BlockView objects as the bricks
 * @param void
 * @return void
 */
-(void)addBlocksToMainView
{
    float yFudgeFactor = 0.0005;
    float xFudgeFactor = 0.001;
    float xOrigin = 0.0;
    float yOrigin = 0.0;
    
    for (int col = 0; col < NUMBER_ROWS; col++)
    {
        for (int row = 0; row < self.view.frame.size.width/BLOCK_WIDTH_EASY; row++)
        {
            //create the block
            //set the blocks position it in the view, the frame takes to CGPoint
            //parameters, the point of the frames origin in the superview, and the
            //point that represents the size of the view
            BlockView *block = [[BlockView alloc]initWithFrame:CGRectMake(xOrigin, yOrigin, BLOCK_WIDTH_EASY, BLOCK_HEIGHT_EASY)];
            block.backgroundColor = [self chooseARandomColorForBlock];
            [self.view addSubview:block];
            
            //add the block to the collison array
            [collisionBehavior addItem:block];
            
            //keep a count of the total blocks
            numberOfBlocks++;
            
            xOrigin += BLOCK_WIDTH_EASY + xFudgeFactor;
        }
        //reset the x origin for the next row
        xOrigin = 0.0;
        
        //increment the y origin by the block height
        yOrigin += BLOCK_HEIGHT_EASY + yFudgeFactor;
    }
}


/*
 * Generate a random UIColor using the colorWithRedGreenBlue method
 * @param void
 * @return UIColor a random RGB UIColor
 */
-(UIColor*)chooseARandomColorForBlock
{
    float red = (arc4random()%256)/255.0;
    float green = (arc4random()%256)/255.0;
    float blue = (arc4random()%256)/255.0;
    
    UIColor *color =[UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    return color;
}

/*
 *
 *
 *
 */
-(BOOL)shouldStartAgain
{
    return YES;
}


/*
 * Reset the game to initial state by nullifying all objects and reinitializing them
 * @param none
 * @return void
 */
-(void)resetGame
{
//    //kill everything
//    dynamicAnimator = nil;
//    collisionBehavior = nil;
//    ballDynamicBehavior = nil;
//    paddleDynamicBehavior = nil;
//    pushBehavior = nil;
//    
//    [self addBlocksToMainView];
//    
//    dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
//
//    [self initializeCollisionBehavior];
//    
//    [self inititalizeDynamicBallBehavior];
//    
//    [self initializeDynamicPaddleBehavior];
//    
//    [self initializePushBehavior];
    
    
}

#pragma mark - Actions


- (IBAction)dragPaddle:(UIPanGestureRecognizer*)panGestureRecognizer
{
    paddleView.center = CGPointMake([panGestureRecognizer locationInView:self.view].x,paddleView.center.y);
    [dynamicAnimator updateItemUsingCurrentState:paddleView];
}


#pragma mark - Collision Detections Delegation Methods

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    //origin.y is the y coordinate relative to the main UIView
    if (ballView.frame.origin.y >= (self.view.frame.size.height-(ballView.frame.size.height*2)))
    {
        ballView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        [dynamicAnimator updateItemUsingCurrentState:ballView];
        [self resetPushBehavior];
    }
}



-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    BlockView *block = (BlockView*)item2;
    
    if([item2 isKindOfClass:[BlockView class]] && block.hits <= 1)
    {
        [UIView animateWithDuration:1.5 animations:^
         {
             block.backgroundColor = [UIColor whiteColor];
         } completion:^(BOOL finished)
         {
             [collisionBehavior removeItem:item2];
             [block removeFromSuperview];
             numberOfBlocks--;
         }];
    }
    else if ([item2 isKindOfClass:[BlockView class]] && block.hits >1)
    {
        
        [UIView animateWithDuration:1.0 animations:^
         {
             block.backgroundColor = [UIColor orangeColor];
             block.hits--;
         } completion:^(BOOL finished)
         {
             
         }];
        
    }
    
    if(numberOfBlocks ==0)
    {
        [self resetGame];
    }
}


-(CGVector)createRandomDownwardVector
{
    float dx = ((float)rand() / RAND_MAX);
    float dy = ((float)rand() / RAND_MAX);
    return CGVectorMake(dx, dy);
}

@end

