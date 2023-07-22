#define collision_check_fast
    ///collision_check_fast(obj)
    return (distance_to_object(instance_nearest(x,y,argument0))<=0)


#define direction_to_object
    ///direction_to_object(obj)
    var __n;
    if (argument0>=100000) __n=argument0
    else __n=instance_nearest(x,y,argument0)
    if (__n==noone) return -1
    return point_direction(x,y,__n.x,__n.y)


#define distance_to_instance
    //you've heard of elf on the shelf, now get ready for 
    ///distance_to_instance(inst)
    var __n;__n=instance_nearest(x,y,argument0)
    if (__n==noone) return -1
    return point_distance(x,y,__n.x,__n.y)


#define instance_create_depth
    ///instance_create_depth(x,y,depth,object)
    var __lastinst;__lastinst=instance_create(argument0,argument1,argument3)
    if (instance_exists(__lastinst)) {
        __lastinst.depth=argument2;
        return __lastinst
    }
    return noone


#define instance_create_depth_moving
    ///instance_create_depth_moving(x,y,depth,object,speed,direction,[gravity,[gravdir]])
    var __lastinst;__lastinst=instance_create_moving(argument0,argument1,argument3,argument4,argument5,argument6,argument7)
    if (instance_exists(__lastinst)) {
        __lastinst.depth=argument2
        return __lastinst
    }
    return noone


#define instance_create_depth_moving_ext
    ///instance_create_depth_moving_ext(x,y,depth,object,speed,direction,[addhspeed,addvspeed,[gravity,[gravdir]]])
    var __lastinst;__lastinst=instance_create_moving_ext(argument0,argument1,argument3,argument4,argument5,argument6,argument7,argument8,argument9)
    if (instance_exists(__lastinst)) {
        __lastinst.depth=argument2
        return __lastinst
    }
    return noone


#define instance_create_moving
    ///instance_create_moving(x,y,object,speed,direction,[gravity,[gravdir]])
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
    with (argument0) instance_destroy()


#define instance_destroy_other
    ///instance_destroy_other()
    with (other) instance_destroy()


#define instance_nearest_notme
    ///instance_nearest_notme(x,y,obj)
    var __oldx,__find;
    
    __oldx=x
    x=-infinity
    __find=instance_nearest(argument0,argument1,argument2)
    x=__oldx
    
    return __find


#define instance_some
    ///instance_some(obj)
    return instance_find(argument0,irandom(instance_number(argument0)-1))


#define move_and_collide
    ///move_and_collide(dx,dy,ind,[_iterations,xoff,yoff,_x_constraint,_y_constraint])
    var ret,dx,dy,ind,num_steps,xoff,yoff,x_constraint,y_constraint;
    var apply_x_constraints,apply_y_constraints;
    var clamp_minx,clamp_miny,clamp_maxx,clamp_maxy;
    var check_perp,delta_length,lxoff,lyoff;
    var steps,ndx,ndy,root2over2,step_dist,dist_to_travel;
    var i,j,this_step_dist,tx,ty,has_moved;

    dx=argument[0]
    dy=argument[1]
    ind=argument[2]

    num_steps=4
    if (argument_count>3) {
        num_steps=argument[3]
    }

    xoff=0
    yoff=0
    if (argument_count>4) {
        xoff=argument[4]
        yoff=argument[5]
    }

    x_constraint=-1
    y_constraint=-1
    if (argument_count>6) {
        x_constraint=argument[6]
        y_constraint=argument[7]
    }

    ret=noone

    if (ind==id || ind==noone || (dx==0 && dy==0)) return ret

    res=instance_place(x,y,ind)
    if (res) return res

    root2over2=0.70710678118654
    steps=sqrt(dx*dx+dy*dy)
    ndx=dx/steps
    ndy=dy/steps
    dist_to_travel=steps
    step_dist=steps/num_steps

    apply_x_constraints=(x_constraint>=0)
    apply_y_constraints=(y_constraint>=0)

    clamp_minx=x-x_constraint
    clamp_miny=y-y_constraint
    clamp_maxx=x+x_constraint
    clamp_maxy=y+y_constraint

    if (xoff==0 && yoff==0) {
        check_perp=true
    } else {
        check_perp=false
        delta_length=sqrt(xoff*xoff+yoff*yoff)
        lxoff=xoff/delta_length
        lyoff=yoff/delta_length
    }

    for (i=0;i<num_steps;i+=1) {
        this_step_dist=step_dist
        if (dist_to_travel<this_step_dist) {
            this_step_dist=dist_to_travel
            if (this_step_dist<=0) break
        }

        tx=x+ndx*this_step_dist
        ty=y+ndy*this_step_dist

        if (apply_x_constraints) tx=clamp(tx,clamp_minx,clamp_maxx)
        if (apply_y_constraints) ty=clamp(ty,clamp_miny,clamp_maxy)

        res=instance_place(tx,ty,ind)
        if (!res) {
            x=tx y=ty
            dist_to_travel-=this_step_dist
        } else {
            ret=res
            has_moved=false
            if (check_perp) {
                for (j=1;j<num_steps-i+1;j+=1) {
                    tx=x+root2over2*(ndx+j*ndy)*this_step_dist
                    ty=y+root2over2*(ndy-j*ndx)*this_step_dist

                    if (apply_x_constraints) tx=clamp(tx,clamp_minx,clamp_maxx)
                    if (apply_y_constraints) ty=clamp(ty,clamp_miny,clamp_maxy)

                    res=instance_place(tx,ty,ind)
                    if (!res) {
                        dist_to_travel-=this_step_dist*j
                        has_moved=true
                        x=tx y=ty
                        break
                    } else ret=res

                    tx=x+root2over2*(ndx-j*ndy)*this_step_dist
                    ty=y+root2over2*(ndy+j*ndx)*this_step_dist

                    if (apply_x_constraints) tx=clamp(tx,clamp_minx,clamp_maxx)
                    if (apply_y_constraints) ty=clamp(ty,clamp_miny,clamp_maxy)

                    res=instance_place(tx,ty,ind)
                    if (!res) {
                        dist_to_travel-=this_step_dist*j
                        has_moved=true
                        x=tx y=ty
                        break
                    } else ret=res
                }
            } else {
                for (j=1;j<num_steps-i+1;j+=1) {
                    tx=x+root2over2*(ndx+j*lxoff)*this_step_dist
                    ty=y+root2over2*(ndy+j*lyoff)*this_step_dist

                    if (apply_x_constraints) tx=clamp(tx,clamp_minx,clamp_maxx)
                    if (apply_y_constraints) ty=clamp(ty,clamp_miny,clamp_maxy)

                    res=instance_place(tx,ty,ind)
                    if (!res) {
                        dist_to_travel-=this_step_dist*j
                        has_moved=true
                        x=tx y=ty
                        break
                    } else ret=res
                }
            }
            if (!has_moved) return ret
        }
    }

    return ret


#define move_towards_gravity
    ///move_towards_gravity(xto,yto,gravity)
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
    with (argument0) return variable_local_exists(argument1)


#define variable_instance_get
    ///variable_instance_get(inst,var)
    with (argument0) return variable_local_get(argument1)


#define variable_instance_set
    ///variable_instance_set(inst,var,val)
    with (argument0) variable_local_set(argument1,argument2)


#define move_contact_solid_h
    ///move_contact_solid_h(maxdist)
    move_contact_solid(90-90*sign(argument0),abs(argument0))

   
#define move_contact_solid_v
    ///move_contact_solid_v(maxdist)
    move_contact_solid(-90*sign(argument0),abs(argument0))


#define position_free
    ///position_free(x,y)
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
//
//
