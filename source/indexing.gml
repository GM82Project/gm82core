#define sprite_find
    ///sprite_find(name)
    //name: Name of the sprite to find.
    //returns: sprite id, or noone
    //Finds a sprite by its name.
    //The first time this function is called, extra time is spent building an index, and subsequent calls are much faster.
    
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
    //name: Name of the sound to find.
    //returns: sound id, or noone
    //Finds a sound by its name. if the sound doesn't exist, noone is returned.
    //The first time this function is called, extra time is spent building an index, and subsequent calls are much faster.
    //Note: if the 8.2 Sound extension is present, it is always fast and returns an empty string on failed search.

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
    //name: Name of the background to find.
    //returns: background id, or noone
    //Finds a background by its name. if the background doesn't exist, noone is returned.
    //The first time this function is called, extra time is spent building an index, and subsequent calls are much faster.

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
    //name: Name of the path to find.
    //returns: path id, or noone
    //Finds a path by its name. if the path doesn't exist, noone is returned.
    //The first time this function is called, extra time is spent building an index, and subsequent calls are much faster.

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
    //name: Name of the font to find.
    //returns: font id, or noone
    //Finds a font resource by its name. if the font doesn't exist, noone is returned.
    //The first time this function is called, extra time is spent building an index, and subsequent calls are much faster.

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
    //name: Name of the timeline to find.
    //returns: timeline id, or noone
    //Finds a timeline by its name. if the timeline doesn't exist, noone is returned.
    //The first time this function is called, extra time is spent building an index, and subsequent calls are much faster.

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
    //name: Name of the object to find.
    //returns: object id, or noone
    //Finds a object by its name. if the object doesn't exist, noone is returned.
    //The first time this function is called, extra time is spent building an index, and subsequent calls are much faster.

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
    //name: Name of the room to find.
    //returns: room id, or noone
    //Finds a room by its name. if the room doesn't exist, noone is returned.
    //The first time this function is called, extra time is spent building an index, and subsequent calls are much faster.

    var l,i;
    if (__gm82core_index_rooms==noone) {
        __gm82core_index_rooms=ds_map_create()
        i=room_first while (i!=room_last) {ds_map_add(__gm82core_index_objects,object_get_name(i),i) i=room_next(i)}
    }
    if (ds_map_exists(__gm82core_index_rooms,argument0)) return ds_map_find_value(__gm82core_index_rooms,argument0)
    return noone