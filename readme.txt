-Game Maker 8.2 Core-

This is a quality of life improvement extension for Game Maker 8.1. It adds a
number of helper functions that are commonly used, and also geometry functions
introduced in GM:Studio. This extension is also required for using the other
GM 8.2 extensions, Sound and Joystick.

[globals]

There's no color coding for those, but they're available as variables.

fps_real
    Gives a slightly faster, but less accurate, measure of frames per second.
    Estimated every 10 frames as opposed to Game Maker's once a second.

delta_time
    Approximate number of milliseconds since last frame.
    Precision was measured to be around 2ms, but it's stable over time.


[constants]

path_action_stop = 0
path_action_restart = 1
path_action_continue = 2
path_action_reverse = 3
    Path end action constants from Studio.
    
infinity = 2305843009213693952
minus_infinity = -2305843009213693952
    Largest representable integers in a GM double.

vk_minus = 189
vk_equals = 187
    Additional keyboard keys.

undefined = "<undefined>"
    String value used in some data structure functions.

core
    Handle to the controller object for gm82core. Keep this object activated.


[geometry functions]

angle_difference(ang1,ang2)
    Returns the relative difference in degrees between the angles.

angle_difference_3d(x1,y1,z1,x2,y2,z2)
    Returns the difference in degrees between the two 3d vectors.

dot_product_normalised(x1,y1,x2,y2)
    Normalized version of dot product.

dot_product_3d_normalised(x1,y1,z1,x2,y2,z2)
    Normalized version of 3d dot product.

point_in_circle(px,py,x1,y1,r)
    Returns whether the point is inside the specified circle.

point_in_rectangle(px,py,x1,y1,x2,y2)
    Returns whether the point is inside the specified rectangle.

point_in_triangle(px,py,x1,y1,x2,y2,x3,y3)
    Returns whether the point is inside the specified triangle.

triangle_is_clockwise(x1,y1,x2,y2,x3,y3)
    Returns whether the sequence of points is clockwise.

lengthdir_zx(len,yaw,pitch)
    Returns the x component of a yaw + pitch angle system.

lengthdir_zy(len,yaw,pitch)
    Returns the y component of a yaw + pitch angle system.

lengthdir_zz(len,yaw,pitch)
    Returns the z component of a yaw + pitch angle system.

point_direction_pitch(x1,y1,z1,x2,y2,z2)
    Returns the pitch component of a 3d vector.
    To use with the above lengthdir functions, use regular point_direction from
    x1,y1 to x2,y2 for the yaw.
    This system simplifies projections and pointing for simple 3d games.


[math functions]

dcos(x)
    Cosine in degrees.

dsin(x)
    Sine in degrees.

dtan(x)
    Tangent in degrees.

darccos(x)
    Arc cosine in degrees.

darcsin(x)
    Arc sine in degrees.

darctan(x)
    Arc tangent in degrees.

cosine(a,b,amount)
    Cosine interpolation from <a> to <b> by specified <amount>.

esign(val,default)
    Returns the <default> argument when the sign of <val> is zero.
    Example:
        image_xscale = esign(hspeed, image_xscale);

gauss(range)
    Returns a gaussian distribution random value within the supplied <range>.

roundto(val,to)
    Rounds <val> to the closest multiple of <to>.

floorto(val,to)
    Floors <val> to the closest multiple of <to>.   
    
ceilto(val,to)
    Ceils <val> to the closest multiple of <to>.    

modwrap(val,min,max)
    Wraps <val> around both directions inside a box defined by <min> and <max>.
    Lower bound is inclusive, upper bound is exclusive.

inch(val,goto,stepsize)
    Approximates <val> to <goto> by <stepsize> amounts until they match.

inch_angle(ang1,ang2,stepsize)
    Approximates angles <ang1> to <ang2> by <stepsize> amounts until they match.

in_range(val,min,max)
    Returns whether val is inbetween min and max.


[studio functions]

alarm_get(index)
    Gets the value of the alarm for the current instance.

alarm_set(index,value)
    Sets the value of the alarm for the current instance.

draw_enable_alphablend(enable)
    Can be used to turn off alpha blending. Useful for drawing screen surfaces.

get_timer()
    Gets the current system time in ms.

string_ord_at(str,pos)
    Gets the character code at position <pos> in the string.

url_open(url)
    Opens a web link in the default browser.

variable_instance_exists(instance_id,name)
    Checks to see if a variable exists in the selected instance.

variable_instance_get(instance_id,name)
    Gets a variable from the selected instance.

variable_instance_set(instance_id,name,value)
    Sets a variable in the selected instance.

window_has_focus()
    Returns whether the game window is currently in front and active.

is_undefined()
    Returns if the value is equal to the undefined constant.


[convenience functions]

instance_create_moving(x,y,object,speed,direction)
    Creates a moving instance and returns its id. Speed and direction are
    applied before the create event executes.

outside_room()
    Returns whether the instance's sprite is completely outside of the room.

mouse_check_direct(button)
    Directly checks the hardware for updated mouse button states.

mouse_back_button()
    Returns if the back button is pressed on mice with navigation controls.

mouse_forward_button()
    Returns if the forward button is pressed on mice with navigation controls.

mouse_in_window()
    Returns if the mouse cursor is currently inside the window rectangle.

registry_read_dword(key,[default])
    Reads a REG_DWORD from the specified key.
    Returns default if the value is not found.

registry_write_dword(key,value)
    Writes a REG_DWORD to the specified key.

window_set_exclusive_fullscreen(full)
    Sets the window mode to exclusive fullscreen, reducing input lag.
    Note: this will destroy all your surfaces!

draw_make_opaque()
    Will make the current surface opaque without changing the colors.

surface_engage(id,width,height):id
    Automatically re-creates a surface when expired, and sets target to it.
    Set the surface id to the return value of this function. Example:
    mySurf=surface_engage(mySurf,400,300);

surface_disengage()
    Resets target, and fixes viewport based on studio behavior.
    
file_text_read_all(fname)
    Reads an entire text file and returns its contents as a string.
    
event_step()
    Executes this instance's normal step event.

window_resize_buffer(w,h)
    Resizes the internal window buffer to a desired resolution.
    Can be used to fix messy pixels when resizing the window.

d3d_reset_projection()
    Restores the current view's projection.

ds_map_read_ini(map,filename)
    Reads an ini file into a dsmap.

ds_map_set(map,key,value)
    Sets a key in the ds map, even if it already exists.

ds_map_get(map,key)
    Returns the key in the ds map, or undefined if it doesn't exist.

instance_destroy_id(id)
    Destroys <id>.

instance_some(object)
    Returns a random instance of the object.

merge_color_corrected(col1,col2,factor)
    Square-corrected color merge.

move_towards_gravity(xto,yto,gravity)
    Sets the instance's trajectory and gravity for an arc towards the point.

pick(which,opt1,opt2,...)
    Picks one of the options based on the first argument.

real_hex(string)
    Converts a hex string into a real.

rgb_to_bgr(color)
    Reverses the blue and red components of a color.

color_get_luminance(color)
    Returns a Kodak-corrected luminance value from a color.

string_hex(real)
    Converts a real into a hex string.

string_number(string)
    A version of string_digits() that also keeps the dot in floats.

string_better(val)
    Regular string() but displaying up to 8 decimal digits.

strong(val1,val2,val3...)
    Concatenates the arguments as strings and returns it.

string_token_start(str,sep)
    Starts splitting <str> by <sep>.

string_token_next()
    Returns the next bit of text before the next <sep> set up earlier.

window_minimize()
    Minimizes the game window. Will reset the application title to room_caption.
    
window_get_caption_color()
    Returns the Windows 8+ accent color.

windows_version()
    Returns the Windows version as a number (xp=5, vista=6, etc. w10 returns 8).


[notes]

-> This extension is required for GM8.2 Sound and GM8.2 Joystick.


- Created by renex && floogle -