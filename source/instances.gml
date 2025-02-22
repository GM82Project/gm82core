#define collision_check_fast
    ///collision_check_fast(obj)
    //obj: object index to check
    //returns: if there was collision
    //performs fast but inaccurate collision checks. Best used with lots of tiny instances e.g. bullets. Avoid long or tall instances like walls.
    
    return (distance_to_object(instance_nearest(x,y,argument0))<=0)


#define direction_to_object
    ///direction_to_object(obj)
    //obj: object or instance to check
    //returns: direction from self to target in degrees
    //If target is an object, the nearest instance is targeted.
    
    var __n;
    if (argument0>=100000) __n=argument0
    else __n=instance_nearest(x,y,argument0)
    if (__n==noone) return -1
    return point_direction(x,y,__n.x,__n.y)


#define distance_to_center
    ///distance_to_center(obj)
    //inst: instance/object to get
    //returns: distance from the centers of self and inst.
    //When given an object id, the nearest instance is used.
    
    var __n;
    if (argument0>=100000) __n=argument0
    else __n=instance_nearest(x,y,argument0)
    if (__n==noone) return -1
    return point_distance(x,y,__n.x,__n.y)


#define instance_create_depth
    ///instance_create_depth(x,y,depth,object)
    //x,y,depth: position
    //object: object index
    //returns: instance id
    
    var __lastinst;__lastinst=instance_create(argument0,argument1,argument3)
    if (instance_exists(__lastinst)) {
        __lastinst.depth=argument2;
        return __lastinst
    }
    return noone


#define instance_create_depth_moving
    ///instance_create_depth_moving(x,y,depth,object,speed,direction,[gravity,[gravdir]])
    //x,y,depth: position
    //object: object index
    //speed,direction: initial velocity
    //gravity, gravdir: gravity settings
    //returns: instance id
    
    if (argument_count<6 || argument_count>8) {
        show_error("can't call instance_create_depth_moving with "+string(argument_count)+" arguments",0)
        return noone
    }
    
    var __lastinst;
    if (argument_count==6) __lastinst=instance_create_moving(argument0,argument1,argument3,argument4,argument5)
    if (argument_count==7) __lastinst=instance_create_moving(argument0,argument1,argument3,argument4,argument5,argument6)
    if (argument_count==8) __lastinst=instance_create_moving(argument0,argument1,argument3,argument4,argument5,argument6,argument7)
    
    if (instance_exists(__lastinst)) {
        __lastinst.depth=argument2
        return __lastinst
    }
    return noone


#define instance_create_depth_moving_ext
    ///instance_create_depth_moving_ext(x,y,depth,object,speed,direction,[addhspeed,addvspeed,[gravity,[gravdir]]])
    //x,y,depth: position
    //object: object index
    //speed,direction: initial velocity
    //addhspeed,addvspeed: component speed to add to initial velocity
    //gravity, gravdir: gravity settings
    //returns: instance id
    
    if (argument_count==7 || argument_count<6 || argument_count>10) {
        show_error("can't call instance_create_depth_moving_ext with "+string(argument_count)+" arguments",0)
        return noone
    }
    
    var __lastinst;
    if (argument_count==6) __lastinst=instance_create_moving_ext(argument0,argument1,argument3,argument4,argument5)
    if (argument_count==8) __lastinst=instance_create_moving_ext(argument0,argument1,argument3,argument4,argument5,argument6,argument7)
    if (argument_count==9) __lastinst=instance_create_moving_ext(argument0,argument1,argument3,argument4,argument5,argument6,argument7,argument8)
    if (argument_count==10) __lastinst=instance_create_moving_ext(argument0,argument1,argument3,argument4,argument5,argument6,argument7,argument8,argument9)
    
    if (instance_exists(__lastinst)) {
        __lastinst.depth=argument2
        return __lastinst
    }
    return noone


#define instance_create_moving
    ///instance_create_moving(x,y,object,speed,direction,[gravity,[gravdir]])
    //x,y: position
    //object: object index
    //speed,direction: initial velocity
    //gravity, gravdir: gravity settings
    //returns: instance id
    
    var __lastinst;__lastinst=instance_count
    action_create_object_motion(argument2,argument0,argument1,argument3,argument4)
    __i=instance_id[__lastinst]
    if (instance_exists(__i)) {
        if (argument_count>5)
            __i.gravity=argument5
        if (argument_count>6)
            __i.gravity_direction=argument6
        return __i
    }
    return noone


#define instance_create_moving_ext
    ///instance_create_moving_ext(x,y,object,speed,direction,[addhspeed,addvspeed,[gravity,[gravdir]]])
    //x,y: position
    //object: object index
    //speed,direction: initial velocity
    //addhspeed,addvspeed: component speed to add to initial velocity
    //gravity, gravdir: gravity settings
    //returns: instance id
    
    var __lastinst,__i,__h,__v;
    
    if (argument_count<5 || argument_count==6 || argument_count>9) {
        show_error("Incorrect set of arguments for function instance_create_moving_ext().",0)
        return noone
    }
    
    __lastinst=instance_count
    if (argument_count>6) {
        __h=lengthdir_x(argument3,argument4)+argument5
        __v=lengthdir_y(argument3,argument4)+argument6        
        action_create_object_motion(
            argument2, //obj
            argument0,argument1, //x,y
            point_distance(0,0,__h,__v),point_direction(0,0,__h,__v) //speed,direction
        )
    } else action_create_object_motion(argument2,argument0,argument1,argument3,argument4)
    
    __i=instance_id[__lastinst]
    if (instance_exists(__i)) {
        if (argument_count>7)
            __i.gravity=argument7
        if (argument_count>8)
            __i.gravity_direction=argument8
        return __i
    }
    return noone


#define instance_destroy_id
    ///instance_destroy_id(obj)
    //obj: instance or object to destroy
    
    with (argument0) instance_destroy()


#define instance_destroy_other
    ///instance_destroy_other()
    //Destroys the other object involved in a collision or with() block.
    
    with (other) instance_destroy()


#define instance_nearest_notme
    ///instance_nearest_notme(x,y,obj)
    //x,y: position to check
    //obj: object to find
    //returns: nearest instance of the object that isn't the same as self
    
    var __oldx,__find;
    
    __oldx=x
    x=-infinity
    __find=instance_nearest(argument0,argument1,argument2)
    x=__oldx
    
    return __find


#define instance_some
    ///instance_some(obj)
    //obj: object to find
    //returns: a random instance of the object
    
    return instance_find(argument0,irandom(instance_number(argument0)-1))


#define move_and_collide
    ///move_and_collide(dx,dy,ind,[iterations,xoff,yoff,x_constraint,y_constraint])
    //dx,dy: offset to move
    //ind: object or instance to collide against
    //iterations: number of collision checks (default 4)
    //xoff,yoff: direction to shove when colliding (default: 0,0)
    //x_constraint,y_constraint: maximum distance to move in each direction
    //returns: if there was collision, the last instance that was hit
    
    var __ret,__dx,__dy,__ind,__num_steps,__xoff,__yoff,__x_constraint,__y_constraint;
    var __apply_x_constraints,__apply_y_constraints;
    var __clamp_minx,__clamp_miny,__clamp_maxx,__clamp_maxy;
    var __check_perp,__delta_length,__lxoff,__lyoff;
    var __steps,__ndx,__ndy,__root2over2,__step_dist,__dist_to_travel;
    var __i,__j,__this_step_dist,__tx,__ty,__has_moved;

    __dx=argument[0]
    __dy=argument[1]
    __ind=argument[2]

    __num_steps=4
    if (argument_count>3) {
        __num_steps=argument[3]
    }

    __xoff=0
    __yoff=0
    if (argument_count>4) {
        __xoff=argument[4]
        __yoff=argument[5]
    }

    __x_constraint=-1
    __y_constraint=-1
    if (argument_count>6) {
        __x_constraint=argument[6]
        __y_constraint=argument[7]
    }

    __ret=noone

    if (__ind==id || __ind==noone || (__dx==0 && __dy==0)) return __ret

    __res=instance_place(x,y,__ind)
    if (__res) return __res

    __root2over2=0.70710678118654
    __steps=sqrt(__dx*__dx+__dy*__dy)
    __ndx=__dx/__steps
    __ndy=__dy/__steps
    __dist_to_travel=__steps
    __step_dist=__steps/__num_steps

    __apply_x_constraints=(__x_constraint>=0)
    __apply_y_constraints=(__y_constraint>=0)

    __clamp_minx=x-__x_constraint
    __clamp_miny=y-__y_constraint
    __clamp_maxx=x+__x_constraint
    __clamp_maxy=y+__y_constraint

    if (__xoff==0 && __yoff==0) {
        __check_perp=true
    } else {
        __check_perp=false
        __delta_length=sqrt(__xoff*__xoff+__yoff*__yoff)
        __lxoff=__xoff/__delta_length
        __lyoff=__yoff/__delta_length
    }

    for (__i=0;__i<__num_steps;__i+=1) {
        __this_step_dist=__step_dist
        if (__dist_to_travel<__this_step_dist) {
            __this_step_dist=__dist_to_travel
            if (__this_step_dist<=0) break
        }

        __tx=x+__ndx*__this_step_dist
        __ty=y+__ndy*__this_step_dist

        if (__apply_x_constraints) __tx=clamp(__tx,__clamp_minx,__clamp_maxx)
        if (__apply_y_constraints) __ty=clamp(__ty,__clamp_miny,__clamp_maxy)

        __res=instance_place(__tx,__ty,__ind)
        if (!__res) {
            x=__tx y=__ty
            __dist_to_travel-=__this_step_dist
        } else {
            __ret=__res
            __has_moved=false
            if (__check_perp) {
                for (__j=1;__j<__num_steps-__i+1;__j+=1) {
                    __tx=x+__root2over2*(__ndx+__j*__ndy)*__this_step_dist
                    __ty=y+__root2over2*(__ndy-__j*__ndx)*__this_step_dist

                    if (__apply_x_constraints) __tx=clamp(__tx,__clamp_minx,__clamp_maxx)
                    if (__apply_y_constraints) __ty=clamp(__ty,__clamp_miny,__clamp_maxy)

                    __res=instance_place(__tx,__ty,__ind)
                    if (!__res) {
                        __dist_to_travel-=__this_step_dist*__j
                        __has_moved=true
                        x=__tx y=__ty
                        break
                    } else __ret=__res

                    __tx=x+__root2over2*(__ndx-__j*__ndy)*__this_step_dist
                    __ty=y+__root2over2*(__ndy+__j*__ndx)*__this_step_dist

                    if (__apply_x_constraints) __tx=clamp(__tx,__clamp_minx,__clamp_maxx)
                    if (__apply_y_constraints) __ty=clamp(__ty,__clamp_miny,__clamp_maxy)

                    __res=instance_place(__tx,__ty,__ind)
                    if (!__res) {
                        __dist_to_travel-=__this_step_dist*__j
                        __has_moved=true
                        x=__tx y=__ty
                        break
                    } else __ret=__res
                }
            } else {
                for (__j=1;__j<__num_steps-__i+1;__j+=1) {
                    __tx=x+__root2over2*(__ndx+__j*__lxoff)*__this_step_dist
                    __ty=y+__root2over2*(__ndy+__j*__lyoff)*__this_step_dist

                    if (__apply_x_constraints) __tx=clamp(__tx,__clamp_minx,__clamp_maxx)
                    if (__apply_y_constraints) __ty=clamp(__ty,__clamp_miny,__clamp_maxy)

                    __res=instance_place(__tx,__ty,__ind)
                    if (!__res) {
                        __dist_to_travel-=__this_step_dist*__j
                        __has_moved=true
                        x=__tx y=__ty
                        break
                    } else __ret=__res
                }
            }
            if (!__has_moved) return __ret
        }
    }

    return __ret


#define move_towards_gravity
    ///move_towards_gravity(xto,yto,gravity)
    //xto,yto: position to hit
    //gravity: gravity value to apply to arc
    //throws self at an arc to hit a specific spot.
    
    var __dX, __dY, __ang;
    
    if (argument2==0) {
        direction=point_direction(x,y,argument0,argument1)
        speed=1
        exit
    }

    gravity=argument2
    __dX=argument0-x
    __dY=argument1-y
    
    if (__dX==0) {
        if (__dY<0) {
            //straight up (we don't do anything for straight down)
            vspeed=-sqrt(__dY*-2/gravity)*gravity-gravity/2
        }
    } else {
        __ang=(arctan2(-__dY,__dX)+degtorad(90))/2
        speed=__dX/(cos(__ang)*sqrt(2*(__dY+tan(__ang)*__dX)/gravity))
        direction=radtodeg(__ang)
    }


#define outside_room
    ///outside_room()
    //returns: whether self is completely outside the room
    
    //workaround for instances without a sprite
    if (bbox_right-bbox_left+bbox_bottom-bbox_top==0)
    return x>=room_width
        || x<0
        || y>=room_height
        || y<0

    return bbox_left>=room_width
        || bbox_right<0
        || bbox_top>=room_height
        || bbox_bottom<0


#define variable_instance_exists
    ///variable_instance_exists(inst,var)
    //Studio shim.
    
    with (argument0) return variable_local_exists(argument1)


#define variable_instance_get
    ///variable_instance_get(inst,var)
    //Studio shim.
    
    with (argument0) return variable_local_get(argument1)


#define variable_instance_set
    ///variable_instance_set(inst,var,val)
    //Studio shim.
    
    with (argument0) variable_local_set(argument1,argument2)


#define move_contact_solid_hv
    ///move_contact_solid_hv(hspeed,vspeed)
    //hspeed,vspeed: distance to move
    //Allows using separate x and y distances for move_contact_solid.
    
    if (argument0!=0 || argument1!=0)
        move_contact_solid(point_direction(0,0,argument0,argument1),ceil(point_distance(0,0,argument0,argument1)))


#define position_free
    ///position_free(x,y)
    //x,y: position to check
    //returns: whether position at x,y is free of solids.
    
    var __mask,__check;

    __mask=mask_index
    __xsc=image_xscale
    __ysc=image_yscale
    __ang=image_angle
    
    mask_index=__gm82core_pixel
    image_xscale=1
    image_yscale=1
    image_angle=0
    
    __check=place_free(argument0,argument1)
    
    mask_index=__mask
    image_xscale=__xsc
    image_yscale=__ysc
    image_angle=__ang

    return __check


#define instance_assign_groups
    ///instance_assign_groups(object,[groupvarname])
    //object: object to look for instances of
    //groupvarname: optional name of the variable to set with the group ids in the instances of the 'object'; default name is "group"
    //Assigns a group id variable to touching chunks of instances in the room. Calling the function again will correctly reapply groups.
    var __name;
    
    __name="group"
    if (argument_count==2) __name=argument[1]
    else if (argument_count!=1) {
        show_error("Error in function instance_assign_groups(): incorrect number of arguments.",0)
        exit
    }
    
    global.__gm82core_groupid=0
    
    with (argument[0]) __gm82core_recurse=true
    with (argument[0]) if (__gm82core_recurse) {
        __gm82core_recursive_group_assign(__name)
        global.__gm82core_groupid+=1
    }


#define __gm82core_recursive_group_assign
    //(groupvarname)
    __gm82core_recurse=false

    with (object_index) if (__gm82core_recurse) if (instance_place(x-1,y,other.id)) __gm82core_recursive_group_assign(argument0)
    with (object_index) if (__gm82core_recurse) if (instance_place(x+1,y,other.id)) __gm82core_recursive_group_assign(argument0)
    with (object_index) if (__gm82core_recurse) if (instance_place(x,y-1,other.id)) __gm82core_recursive_group_assign(argument0)
    with (object_index) if (__gm82core_recurse) if (instance_place(x,y+1,other.id)) __gm82core_recursive_group_assign(argument0)

    variable_local_set(argument0,global.__gm82core_groupid)    


#define move_wrap
    //(hor,vert,margin)
    var __margin;__margin=argument2
    if (argument0) {
        //horizontal
        if (bbox_right+1<-__margin) x+=room_width+__margin-bbox_left
        else if (bbox_left>room_width+__margin) x-=bbox_right+1+__margin
    }
    if (argument1) {
        //vertical
        if (bbox_bottom+1<-__margin) y+=room_height+__margin-bbox_top
        else if (bbox_top>room_height+__margin) y-=bbox_bottom+1+__margin
    }
//
//
