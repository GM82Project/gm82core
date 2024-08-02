#define sprite_find
    ///sprite_find(name)
    var l,i;
    if (__gm82core_index_sprites==noone) {
        __gm82core_index_sprites=ds_map_create()
        l=sprite_create_from_screen(0,0,1,1,0,0,0,0) sprite_delete(l)
        i=0 repeat (l) {if (sprite_exists(i)) ds_map_add(__gm82core_index_sprites,sprite_get_name(i),i) i+=1}
    }
    if (ds_map_exists(__gm82core_index_sprites,argument0)) return ds_map_find_value(__gm82core_index_sprites,argument0)
    return noone


#define sound_find
    ///sound_find(name)
    var l,i;
    globalvar __gm82snd_version;
    if (__gm82snd_version>0) {
        //hello, gm82snd
        if (sound_exists(argument0)) return argument0
        return ""
    } else {
        //builtin gm, make an index
        if (__gm82core_index_sounds==noone) {
             __gm82core_index_sounds=ds_map_create()
            l=sound_add("c:\windows\media\flourish.mid",1,0) sound_delete(l)
            i=0 repeat (l) {if (sound_exists(i)) ds_map_add(__gm82core_index_sounds,sound_get_name(i),i) i+=1}
        }        
        if (ds_map_exists(__gm82core_index_sounds,argument0)) return ds_map_find_value(__gm82core_index_sounds,argument0)
        return noone    
    }
    

#define background_find
    ///background_find(name)
    var l,i;
    if (__gm82core_index_backgrounds==noone) {
        __gm82core_index_backgrounds=ds_map_create()
        l=background_create_color(1,1,0) background_delete(l)
        i=0 repeat (l) {if (background_exists(i)) ds_map_add(__gm82core_index_backgrounds,background_get_name(i),i) i+=1}
    }
    if (ds_map_exists(__gm82core_index_backgrounds,argument0)) return ds_map_find_value(__gm82core_index_backgrounds,argument0)
    return noone


#define path_find
    ///path_find(name)
    var l,i;
    if (__gm82core_index_paths==noone) {
        __gm82core_index_paths=ds_map_create()
        l=path_add() path_delete(l)
        i=0 repeat (l) {if (path_exists(i)) ds_map_add(__gm82core_index_paths,path_get_name(i),i) i+=1}
    }
    if (ds_map_exists(__gm82core_index_paths,argument0)) return ds_map_find_value(__gm82core_index_paths,argument0)
    return noone


#define font_find
    ///font_find(name)
    var l,i,spr;
    if (__gm82core_index_fonts==noone) {
        __gm82core_index_fonts=ds_map_create()
        l=font_add("Arial",10,0,0,32,32) font_delete(l)
        i=0 repeat (l) {if (font_exists(i)) ds_map_add(__gm82core_index_fonts,font_get_name(i),i) i+=1}
    }
    if (ds_map_exists(__gm82core_index_fonts,argument0)) return ds_map_find_value(__gm82core_index_fonts,argument0)
    return noone


#define timeline_find
    ///timeline_find(name)
    var l,i;
    if (__gm82core_index_timelines==noone) {
        __gm82core_index_timelines=ds_map_create()
        l=timeline_add() timeline_delete(l)
        i=0 repeat (l) {if (timeline_exists(i)) ds_map_add(__gm82core_index_timelines,timeline_get_name(i),i) i+=1}
    }
    if (ds_map_exists(__gm82core_index_timelines,argument0)) return ds_map_find_value(__gm82core_index_timelines,argument0)
    return noone


#define object_find
    ///object_find(name)
    var l,i;
    if (__gm82core_index_objects==noone) {
        __gm82core_index_objects=ds_map_create()
        l=object_add() object_delete(l)
        i=0 repeat (l) {if (object_exists(i)) ds_map_add(__gm82core_index_objects,object_get_name(i),i) i+=1}
    }
    if (ds_map_exists(__gm82core_index_objects,argument0)) return ds_map_find_value(__gm82core_index_objects,argument0)
    return noone

#define room_find
    ///room_find(name)
    var l,i;
    if (__gm82core_index_rooms==noone) {
        __gm82core_index_rooms=ds_map_create()
        i=room_first while (i!=room_last) {ds_map_add(__gm82core_index_objects,object_get_name(i),i) i=room_next(i)}
    }
    if (ds_map_exists(__gm82core_index_rooms,argument0)) return ds_map_find_value(__gm82core_index_rooms,argument0)
    return noone