#define draw_background_tiled_extra
    ///draw_background_tiled_extra(back,x,y,xscale,yscale,angle,color,alpha,hrepeats,vrepeats)

    var __bg,__dx,__dy,__xs,__ys,__angle,__color,__alpha,__hrep,__vrep;

    __bg=argument0
    __dx=argument1 __dy=argument2
    __xs=argument3 __ys=argument4
    __angle=modwrap(argument5,0,360)
    __color=argument6 __alpha=argument7
    __hrep=argument8 __vrep=argument9

    var __tex,__w,__h,__u,__v,__angadd,__length;

    __tex=background_get_texture(__bg)
    __w=background_get_width(__bg)*__xs
    __h=background_get_height(__bg)*__ys
    
    //       ????????
    if (__w==0 || __h==0) exit

    texture_set_repeat(1)
    draw_primitive_begin_texture(pr_trianglestrip,__tex)    
            
    if (__hrep>0 && __vrep>0) {
        if (__xs=0 || __ys=0) exit
        __u=__dx __v=__dy
        draw_vertex_texture_color(__u-0.5,__v-0.5,0,0,__color,__alpha)
        __u=__dx+dcos(__angle)*__w*__hrep __v=__dy-dsin(__angle)*__w*__hrep
        draw_vertex_texture_color(__u-0.5,__v-0.5,__hrep,0,__color,__alpha)
        __u=__dx+dcos(__angle-90)*__h*__vrep __v=__dy-dsin(__angle-90)*__h*__vrep
        draw_vertex_texture_color(__u-0.5,__v-0.5,0,__vrep,__color,__alpha)
        __u=__dx+pivot_pos_x(__w*__hrep,__h*__vrep,__angle) __v=__dy+pivot_pos_y(__w*__hrep,__h*__vrep,__angle)
        draw_vertex_texture_color(__u-0.5,__v-0.5,__hrep,__vrep,__color,__alpha)        
    } else if (__hrep>0 || __vrep>0) {
        if (__xs=0 || __ys=0) exit //zero scale would produce a degenerate quad anyway
        __angadd=-__angle
        if (__hrep>0) {
            //vertical infinity; rotate uv logic 90 degrees
            __length=__w*__hrep __angle+=90
        } else {
            //horizontal infinity
            __length=__h*__vrep
        }
        
        if (__angle<45 || __angle>315 || (__angle>135 && __angle<225)) {
            //horizontal infinite tiler
            __u=0 repeat (2) {__v=__dy+(__dx-__u)*dtan(__angle) repeat (2) {
                draw_vertex_texture_color(__u-0.5,__v-0.5,pivot_pos_x(__u-__dx,__v-__dy,__angadd)/__w,pivot_pos_y(__u-__dx,__v-__dy,__angadd)/__h,__color,__alpha)
            __v+=__length*dsecant(__angle)} __u=room_width}
        } else {
            //vertical infinite tiler
            __v=0 repeat (2) {__u=__dx+(__dy-__v)*dtan(90-__angle) repeat (2) {
                draw_vertex_texture_color(__u-0.5,__v-0.5,pivot_pos_x(__u-__dx,__v-__dy,__angadd)/__w,pivot_pos_y(__u-__dx,__v-__dy,__angadd)/__h,__color,__alpha)
            __u+=__length*dsecant(90-__angle)} __v=room_height}
        }    
    } else {
        if (__xs=0 || __ys=0) {
            //infinite scale mode
            __u=0 repeat (2) {__v=0 repeat (2) {
                draw_vertex_texture_color(__u-0.5,__v-0.5,0.5,0.5,__color,__alpha)
            __v=room_height} __u=room_width}
        } else {
            //cover room mode
            __u=0 repeat (2) {__v=0 repeat (2) {
                draw_vertex_texture_color(__u-0.5,__v-0.5,pivot_pos_x(__u-__dx,__v-__dy,__angle)/__w,pivot_pos_y(__u-__dx,__v-__dy,__angle)/__h,__color,__alpha)
            __v=room_height} __u=room_width}
        }
    }

    draw_primitive_end()


#define draw_reset
    ///draw_reset()
    draw_set_color($ffffff)
    draw_set_alpha(1)
    draw_set_halign(0)
    draw_set_valign(0)


#define draw_self_as
    ///draw_self_as(sprite,[image])
    var __img;__img=-1
    if (argument_count>1) __img=floor(argument1)
    draw_sprite_ext(argument0,__img,x,y,image_xscale,image_yscale,image_angle,image_blend,image_alpha)


#define draw_self_floored
    ///draw_self_floored()
    draw_sprite_ext(sprite_index,-1,floor(x),floor(y),image_xscale,image_yscale,image_angle,image_blend,image_alpha)


#define draw_set1
    ///draw_set1(color,alpha)
    draw_set_color(argument0)
    draw_set_alpha(argument1)


#define draw_set2
    ///draw_set2(halign,valign)
    draw_set_halign(argument0)
    draw_set_valign(argument1)


#define draw_set_rgba
    ///draw_set_rgba(r,g,b,a)
    draw_set_color(make_color_rgb(argument0,argument1,argument2))
    draw_set_alpha(argument3)


#define draw_sprite_ext_fixed
    ///draw_sprite_ext_fixed(sprite,image,x,y,xscale,yscale,angle,color,alpha)
    draw_sprite_ext(
        argument0,floor(argument1),
        argument2+lengthdir_x(0.5,argument6)+lengthdir_x(0.5,argument6-90),
        argument3+lengthdir_y(0.5,argument6)+lengthdir_y(0.5,argument6-90),
        argument4,argument5,argument6,argument7,argument8
    )


#define draw_text_1color
    ///draw_text_1color(x,y,string,color,alpha)
    draw_text_color(argument0,argument1,argument2,argument3,argument3,argument3,argument3,argument4)
//
//