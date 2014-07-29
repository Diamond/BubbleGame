//
//  BRMyScene.m
//  Bubbles
//
//  Created by Brandon Richey on 7/28/14.
//  Copyright (c) 2014 Brandon Richey. All rights reserved.
//

#import "BRMyScene.h"

@implementation BRMyScene {
    SKSpriteNode *_bubble;
}

static const CGFloat  MIN_ANGLE        = 0.0f;
static const CGFloat  MAX_ANGLE        = 360.0f * M_PI / 180.0f;
static const CGFloat  BUBBLE_SPEED     = 50.0f;
static const uint32_t EDGE_CATEGORY    = 0x1 << 0;
static const uint32_t BUBBLE_CATEGORY  = 0x1 << 1;
static const int      STARTING_BUBBLES = 20;

static inline CGVector radiansToVector(CGFloat radians)
{
    CGVector vector;
    vector.dx = cosf(radians);
    vector.dy = sinf(radians);
    return vector;
}

static inline CGFloat randomInRange(CGFloat low, CGFloat high)
{
    CGFloat value = arc4random_uniform(UINT32_MAX) / (CGFloat)UINT32_MAX;
    return value * (high - low) + low;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
        for (int i = 0; i < STARTING_BUBBLES; i++) {
            [self addBubble];
        }
        [self addEdges];
    }
    return self;
}

-(void)addEdges
{
    SKNode *leftEdge = [[SKNode alloc] init];
    leftEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height)];
    leftEdge.position = CGPointZero;
    leftEdge.physicsBody.categoryBitMask = EDGE_CATEGORY;
    
    SKNode *rightEdge = [[SKNode alloc] init];
    rightEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height)];
    rightEdge.position = CGPointMake(self.size.width, 0.0f);
    rightEdge.physicsBody.categoryBitMask = EDGE_CATEGORY;
    
    SKNode *topEdge = [[SKNode alloc] init];
    topEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(self.size.width, 0.0f)];
    topEdge.position = CGPointMake(0.0f, self.size.height);
    topEdge.physicsBody.categoryBitMask = EDGE_CATEGORY;
    
    SKNode *bottomEdge = [[SKNode alloc] init];
    bottomEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(self.size.width, 0.0f)];
    bottomEdge.position = CGPointMake(0.0f, 0.0f);
    bottomEdge.physicsBody.categoryBitMask = EDGE_CATEGORY;
    
    [self addChild:leftEdge];
    [self addChild:rightEdge];
    [self addChild:topEdge];
    [self addChild:bottomEdge];
}

-(void)addBubble
{
    _bubble = [SKSpriteNode spriteNodeWithImageNamed:@"bluebubble"];
    _bubble.size = CGSizeMake(8.0f, 8.0f);
    _bubble.anchorPoint = CGPointMake(0.5f, 0.5f);
    _bubble.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:8.0f];
    _bubble.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    CGVector direction = radiansToVector(randomInRange(MIN_ANGLE, MAX_ANGLE));
    _bubble.physicsBody.velocity = CGVectorMake(direction.dx * BUBBLE_SPEED, direction.dy * BUBBLE_SPEED);
    _bubble.physicsBody.categoryBitMask = BUBBLE_CATEGORY;
    _bubble.physicsBody.collisionBitMask = EDGE_CATEGORY;
    _bubble.physicsBody.affectedByGravity = FALSE;
    _bubble.physicsBody.restitution = 1.0f;
    _bubble.physicsBody.linearDamping = 0.0f;
    _bubble.physicsBody.friction = 0.0f;
    [self addChild:_bubble];
}

-(void)addExplosionAt:(CGPoint)position
{
    SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithImageNamed:@"explosion"];
    explosion.size          = CGSizeMake(8.0f, 8.0f);
    explosion.anchorPoint   = CGPointMake(0.5f, 0.5f);
    explosion.position      = position;
    SKAction *expand        = [SKAction scaleBy:10.0f duration:3.0f];
    SKAction *disappear     = [SKAction removeFromParent];
    SKAction *sequence      = [SKAction sequence:@[expand, disappear]];
    [explosion runAction:sequence];
    [self addChild:explosion];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint position = [touch locationInNode:self];
        [self addExplosionAt:position];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
