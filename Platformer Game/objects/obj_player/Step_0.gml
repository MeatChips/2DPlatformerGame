#region Variables

// Check if you are grounded
var isGrounded = place_meeting(x, y + groundBuffer, collideWith); 

// Movement Controls
var leftKey = keyboard_check(ord("A"));
var rightKey = keyboard_check(ord("D"));
var jumpKey = keyboard_check_pressed(vk_space);

#endregion

#region Horizontal Movement
// Get move direction
var dir = rightKey - leftKey;

if (dir != 0) {
    image_xscale = dir; // Flip sprite based on direction
}

horizontalSpeed += dir * accel;

if(dir == 0) // No direction
{
    if(horizontalSpeed < 0) // Left
    {
        horizontalSpeed = min(horizontalSpeed + decel, 0);
    } else // Right
    {
        horizontalSpeed = max(horizontalSpeed - decel, 0);
    }
}

horizontalSpeed = clamp(horizontalSpeed, -horizontalSpeedMax, horizontalSpeedMax); // Max speed

#endregion

#region Vertical Movement
// Add gravity
verticalSpeed += grav;

// Jumping 
if(jumpBuffer > 0) // Checks if the jumpbuffer is greater than 0
{
    jumpBuffer--; // Reduces jumpbuffer by 1 each step
    if(jumpKey && verticalSpeed > 0) // Presses jump key and player not grounded
    {
        jumpBuffer = 0; // Set jumpBuffer to 0
        verticalSpeed = jumpHeight; // Jump up
        canDoubleJump = true; // Enable double jump 
    }
}
else if(canDoubleJump && jumpKey) // If the player hasn't double jumped yet
{
    verticalSpeed = doubleJumpHeight; // Jump up AGAIN
    canDoubleJump = false; // Disable double jump
}

if(isGrounded) // Check if you are grounded
{
    jumpBuffer = 10; // Reset jump buffer value when grounded
    canDoubleJump = true;// Enable double jump 
}

#endregion

#region Collisions

// Horizontal collision
if(place_meeting(x + horizontalSpeed, y, collideWith))
{
    var xx = round(x);
    var pixel = sign(horizontalSpeed);
    
    while(!place_meeting(xx + pixel, y, collideWith))
    {
        xx += pixel;
    }
    
    x = xx;
    horizontalSpeed = 0;
}

// Commit movement
x += horizontalSpeed;

// Vertical collision
if(place_meeting(x, y + verticalSpeed, collideWith))
{
    var yy = round(y);
    var pixel = sign(verticalSpeed);
    
    while(!place_meeting(x, yy + pixel, collideWith))
    {
        yy += pixel;
    }
    
    y = yy;
    verticalSpeed = 0;
}

// Commit movement
y += verticalSpeed;

#endregion

#region Camera

var camX = camera_get_view_x(view_camera[0]);
var camY = camera_get_view_y(view_camera[0]);

var targetX = x - (camera_get_view_width(view_camera[0]) / 2);
var targetY = y - (camera_get_view_height(view_camera[0]) / 2);

camX = lerp(camX, targetX, 0.1); // Adjust 0.1 for smoothness
camY = lerp(camY, targetY, 0.1); // Adjust 0.1 for smoothness

camera_set_view_pos(view_camera[0], camX, camY);

#endregion

#region HP and Respawning

// Check if there is collision with the spike
if (place_meeting(x, y, obj_spike)) {
    if (!damageTaken) {
        // Reduce health by only once
        hp--;

        // Respawn if health is smaller or equal to zero
        if (hp <= 0) {
            
            // Reset to original position
            x = originalPosX;      
            y = originalPosY;
            
            // Reset health
            hp = 3;          
            
            // Stop movement      
            horizontalSpeed = 0;   
            verticalSpeed = 0;
        } else {
            // Apply knockback to the player when you are not respawning
            
            // Knockback direction away from the spike
            var knockbackDir = point_direction(x, y, obj_spike.x, obj_spike.y) + 225; 
            
            // Calculate how much the player should move horizontally and vertically
            // based on the direction and the knockback force.
            horizontalSpeed = lengthdir_x(knockbackForce, knockbackDir);
            verticalSpeed = lengthdir_y(knockbackForce, knockbackDir);
        }

        // Damage is taken
        damageTaken = true;
    }
} else {
    // Reset damageTaken when there is no more collision with a spike
    damageTaken = false;
}

#endregion