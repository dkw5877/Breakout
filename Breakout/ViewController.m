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
#define BLOCK_WIDTH_HARD 10
#define BLOCK_HEIGHT_HARD 40
#define NUMBER_ROWS 1


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
    
    [self addBlocksToMainView];
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


#pragma mark - Method to modify existing behaviors

-(void)resetPushBehaviorWithVector:(CGVector)vector
{
    CGVector reversedDirection = vector;
    pushBehavior = nil;
    pushBehavior = [[UIPushBehavior alloc]initWithItems:@[ballView] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = reversedDirection;
    pushBehavior.active = YES;
    pushBehavior.magnitude =  0.1;
    [dynamicAnimator addBehavior:pushBehavior];
}

#pragma mark - Helper methods to create bricks with random colors
/*
 * Generate a matrix of BlockView objects as the bricks
 * @param void
 * @return void
 */
-(void)addBlocksToMainView
{
    float yFudgeFactor = 0.0005;
    float xFudgeFactor = 0.01;
    float xOrigin = 0.0;
    float yOrigin = 0.0;
    NSMutableArray *dynamicItemsArray = [NSMutableArray new];
    
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
            
            //add the block to the array
            [dynamicItemsArray addObject:block];
            
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
    
    //add the blocks to the block dynamic behavior
    blockDynamicBehavior = [[UIDynamicItemBehavior alloc]initWithItems:dynamicItemsArray];
    blockDynamicBehavior.density = 1000.0;
    blockDynamicBehavior.elasticity = 0.0;
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
    //move the ball back to the center
    ballView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [dynamicAnimator updateItemUsingCurrentState:ballView];
    [self addBlocksToMainView];
    
    //add a downward velocity
    [ballDynamicBehavior addLinearVelocity:CGPointMake(200, 400.0) forItem:ballView];
    
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
        
        float dx = 0.0;
        
        if(arc4random()%2 == 0)
        {
            dx = 200.0;
        }
        else
        {
            dx = -200.0;
        }
        
        //add a downward velocity, either to left or to right
        [ballDynamicBehavior addLinearVelocity:CGPointMake(dx, 500.0) forItem:ballView];
        
        //update the ball
        [dynamicAnimator updateItemUsingCurrentState:ballView];
    }
}


#pragma mark - CollisionBehaviorDelegate Methods


-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    BlockView *block1 = (BlockView*)item1;
    BlockView *block2 = (BlockView*)item2;
    
    if([item2 isKindOfClass:[BlockView class]] && block2.hits <= 1)
    {
        [UIView animateWithDuration:1.5 animations:^
         {
            block2.backgroundColor = [UIColor whiteColor];
            [self decrementNumberOFBlocks];
             
         } completion:^(BOOL finished)
         {
             [collisionBehavior removeItem:item2];
             [block2 removeFromSuperview];
             
         }];
    }
    else if ([item1 isKindOfClass:[BlockView class]] && block1.hits <= 1)
    {
        [UIView animateWithDuration:1.5 animations:^
         {
             block1.backgroundColor = [UIColor whiteColor];
             [self decrementNumberOFBlocks];
         } completion:^(BOOL finished)
         {
             [collisionBehavior removeItem:item1];
             [block1 removeFromSuperview];
             
         }];
    }
    else if ([item2 isKindOfClass:[BlockView class]] && block2.hits > 1)
    {
        
        [UIView animateWithDuration:1.0 animations:^
         {
             block2.backgroundColor = [UIColor orangeColor];
             block2.hits--;
         } completion:^(BOOL finished)
         {
             
         }];
    }
    else if ([item1 isKindOfClass:[BlockView class]] && block1.hits > 1)
    {
        [UIView animateWithDuration:1.0 animations:^
         {
             block1.backgroundColor = [UIColor orangeColor];
             block1.hits--;
         } completion:^(BOOL finished)
         {
             
         }];
    }

    //NSLog(@"number of blocks %i", numberOfBlocks);
    
    if(numberOfBlocks == 0)
    {
        [self stopBallAtCurrentLocation];
        [self raiseGameOverAlert];
    }
    
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

