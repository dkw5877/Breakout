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

#define BLOCK_WIDTH_EASY 50
#define BLOCK_HEIGHT_EASY 50
#define BLOCK_WIDTH_HARD 30
#define BLOCK_HEIGHT_HARD 30
#define NUMBER_ROWS 3


#define VECTOR_UP (0.0,-1.0)
#define VECTOR_DOWN (0.0,1.0)
#define VECTOR_DOWN_RIGHT  (0.5, 1.0)
#define VECTOR_DOWN_LEFT (0.0,1.0)


@interface ViewController () <UIAlertViewDelegate>
{
    UIDynamicAnimator *dynamicAnimator;
    UIPushBehavior* pushBehavior;
    UICollisionBehavior *collisionBehavior;
    UIGravityBehavior *gravityBehavior;
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
    
    numberOfBlocks = 0;
    
    dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    [self initializePushBehavior];
    
    [self initializeCollisionBehavior];

    [self inititalizeDynamicBallBehavior];
    
    [self initializeDynamicPaddleBehavior];
    
    [self addBlocksToMainView:NUMBER_ROWS withWidth:BLOCK_WIDTH_HARD height:BLOCK_HEIGHT_HARD];
}

#pragma mark - Initialization Methods for Dynamic Behaviors

- (void)inititalizeDynamicBallBehavior
{
    ballDynamicBehavior = [[UIDynamicItemBehavior alloc]initWithItems:@[ballView]];
    ballDynamicBehavior.allowsRotation = NO;
    ballDynamicBehavior.density = 0.30;
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
    paddleDynamicBehavior.elasticity = 1.0;
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
    pushBehavior.magnitude =  0.05;
    [dynamicAnimator addBehavior:pushBehavior];
}


#pragma mark - Method to modify existing behaviors


#pragma mark - Helper methods to create bricks with random colors
/*
 * Generate a matrix of BlockView objects as the bricks
 * @param void
 * @return void
 */
-(void)addBlocksToMainView:(int)numberOfRows withWidth:(int)blockWidth height:(int)blockHeight
{
    float yFudgeFactor = 0.05;
    float xFudgeFactor = 0.01;
    float xOrigin = 0.0;
    float yOrigin = 0.0;
    NSMutableArray *dynamicItemsArray = [NSMutableArray new];
    
    for (int col = 0; col < numberOfRows; col++)
    {
        for (int row = 0; row < self.view.frame.size.width/blockWidth; row++)
        {
            //create the block
            //set the blocks position it in the view, the frame takes to CGPoint
            //parameters, the point of the frames origin in the superview, and the
            //point that represents the size of the view
            BlockView *block = [[BlockView alloc]initWithFrame:CGRectMake(xOrigin, yOrigin, blockWidth, blockHeight)];
            block.backgroundColor = [self chooseARandomColorForBlock];
            
            [self.view addSubview:block];
            
            //add the block to the array
            [dynamicItemsArray addObject:block];
            
            //add the block to the collison array
            [collisionBehavior addItem:block];
            
            //keep a count of the total blocks
            numberOfBlocks++;
            
            xOrigin += blockWidth + xFudgeFactor;
        }
        //reset the x origin for the next row
        xOrigin = 0.0;
        
        //increment the y origin by the block height
        yOrigin += blockHeight + yFudgeFactor;
    }
    
    //add the blocks to the block dynamic behavior
    blockDynamicBehavior = [[UIDynamicItemBehavior alloc]initWithItems:dynamicItemsArray];
    blockDynamicBehavior.density = 1.0;
    blockDynamicBehavior.elasticity = 0.5;
    blockDynamicBehavior.friction = 0.0;
    blockDynamicBehavior.allowsRotation = NO;
    dynamicItemsArray = nil;
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
    //remove any remaining blocks not cleared
    for (BlockView *block in self.view.subviews)
    {
        if ([block isKindOfClass:[BlockView class]])
        {
            [block removeFromSuperview];
        }
    }
    //move the ball back to the center
    ballView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [dynamicAnimator updateItemUsingCurrentState:ballView];
    [self addBlocksToMainView:NUMBER_ROWS withWidth:BLOCK_WIDTH_HARD height:BLOCK_HEIGHT_HARD];
    
    //add a downward velocity
    [ballDynamicBehavior addLinearVelocity:CGPointMake(200, 200.0) forItem:ballView];
    
}


- (void)decrementNumberOFBlocks
{
    if (numberOfBlocks > 0)
    {
        numberOfBlocks--;
    }
}


/*
 * Stop ball moving by reversing the linear velocity to zero.
 */
-(void)stopBallAtCurrentLocation
{
    //stop the ball from moving
    CGPoint ballLinearVelocity = [ballDynamicBehavior linearVelocityForItem:ballView];
    CGPoint reverseBallLinearVelocity = CGPointMake((ballLinearVelocity.x*-1), (ballLinearVelocity.y*-1));
    [ballDynamicBehavior addLinearVelocity:reverseBallLinearVelocity forItem:ballView];
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
        //stop the ball
        [self stopBallAtCurrentLocation];
        
        //move the ball back to the center
        ballView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/4);
        
        float xVelocity = 100.0;
        
        if(arc4random()%2 == 0)
        {
            xVelocity *= -1.0;
        }
        
        //add a downward velocity, either to left or to right
        [ballDynamicBehavior addLinearVelocity:CGPointMake(xVelocity, 200.0) forItem:ballView];
        
        //update the ball
        [dynamicAnimator updateItemUsingCurrentState:ballView];
    }
}


#pragma mark - CollisionBehaviorDelegate Methods

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    
    if(([item1 isKindOfClass:[PaddleView class]] && [item2 isKindOfClass:[BallView class]]) ||
        ([item1 isKindOfClass:[BallView class]] && [item2 isKindOfClass:[PaddleView class]]) )
    {
        [self collisionItemsAreBAllAndPaddle];
    }
    
    else if([item1 isKindOfClass:[BlockView class]] && [item2 isKindOfClass:[BlockView class]] )
    {
        //do nothing if two blocks hit each other
    }
    
    else if([item1 isKindOfClass:[BlockView class]] && [item2 isKindOfClass:[BallView class]])
    {
        [self blockHitByBall:item1];
    }
    else if([item1 isKindOfClass:[BallView class]] && [item2 isKindOfClass:[BlockView class]])
    {
        [self blockHitByBall:item2];
    }
    
    if(numberOfBlocks == 0)
    {
        [self stopBallAtCurrentLocation];
        [self raiseGameOverAlert];
    }
    
}


/*
 * When a block is hit by the ball, decrement the hits count of the block
 * When the hit count reaches zero remove it from the screen and the collison
 * behavior array
 */
-(void)blockHitByBall:(id<UIDynamicItem>)item
{
    BlockView* block = (BlockView*)item;
    
    if (block.hits <= 1)
    {
        [UIView animateWithDuration:1.5 animations:^
         {
             block.backgroundColor = [UIColor whiteColor];
             [self decrementNumberOFBlocks];
             
         } completion:^(BOOL finished)
         {
             [collisionBehavior removeItem:item];
             [block removeFromSuperview];
         }];
    }
    else
    {
        [UIView animateWithDuration:1.0 animations:^
         {
             block.backgroundColor = [UIColor orangeColor];
             block.hits--;
         } completion:^(BOOL finished)
         {
             
         }];
    }
}

/*
 * If the ball collides with the paddle, add an upward Y velocity to the ball
 * alter the X velocity to go left or right to prevent the ball from just going
 * straight up and down indefinitely
 */
-(void)collisionItemsAreBAllAndPaddle

{
    CGPoint ballLinearVelocity = [ballDynamicBehavior linearVelocityForItem:ballView];
    //NSLog(@"initial velocity x:%f y:%f",ballLinearVelocity.x,ballLinearVelocity.y);
    
    CGPoint reverseBallLinearVelocity = CGPointMake((ballLinearVelocity.x*-1), (ballLinearVelocity.y*-1));
    CGPoint ballUpwardTrajectory = CGPointMake([self calculateRandomFloatValueForXVelocity], -450.0);
    
    //
    [ballDynamicBehavior addLinearVelocity:reverseBallLinearVelocity forItem:ballView];
    [ballDynamicBehavior addLinearVelocity:ballUpwardTrajectory forItem:ballView];
}


/*
 * Calcualte a random number bewteen 0 and 3, then multiply by 100
 * This will serve as a random X velocity factor. It will alternate
 * beteen negative and positive randomly
 */
-(float)calculateRandomFloatValueForXVelocity
{
    float xVelocity = (arc4random()%3 *100);
    
    if (arc4random()%2 == 0)
    {
        xVelocity *= -1.0;
        NSLog(@"xVelocity: %f",xVelocity);
    }
    
    return xVelocity;
}


#pragma mark - UIAlertViewDelegate Methods

-(void)raiseGameOverAlert
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Game Over" message:@"All blocks cleared, restart?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Start New Game", nil];
    
    [alertView show];
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self resetGame];
    }
}

@end

