#define alarm_get
    ///alarm_get(numb)
    //numb - alarm index
    //Similar to Studio function. Gets the value of an instance alarm.
    
    return alarm[argument0]


#define alarm_set
    ///alarm_set(numb,steps)
    //numb - alarm index
    //Similar to Studio function. Sets the value of an instance alarm.
    
    alarm[argument0]=argument1


#define animation_stop
    ///animation_stop()
    //Stops the instance's animation on the last frame.
    //Particularly useful for Animation end events.
    
    image_speed=0
    image_index=image_number-1


#define event_alarm
    ///event_alarm(numb)
    //numb - alarm index
    //Shortcut function. Executes the actions in the Alarm event indicated.
    
    event_perform(ev_alarm,argument0)


#define event_beginstep
    ///event_beginstep()
    //Shortcut function. Executes the actions in the Begin Step event.
    
    event_perform(ev_step,ev_step_begin)


#define event_draw
    ///event_draw()
    //Shortcut function. Executes the actions in the Draw event.
    
    event_perform(ev_draw,0)


#define event_endstep
    ///event_endstep()
    //Shortcut function. Executes the actions in the End Step event.
    
    event_perform(ev_step,ev_step_end)


#define event_inherit_object
    ///event_inherit_object(object)
    //object: real - object to inherit
    //Executes the same event from a different object.
    
    event_perform_object(argument0,event_type,event_number)


#define event_step
    ///event_step()
    //Shortcut function. Executes the actions in the Step event.
    
    event_perform(ev_step,ev_step_normal)


#define event_trigger
    ///event_trigger(trig)
    //trig: real - trigger constant
    //Shortcut function. Executes a trigger event.
    
    event_perform(ev_trigger,argument0)


#define object_is_child_of
    ///object_is_child_of(object)
    //object: real - object to check
    //Checks if the instance is a child of or the object itself.
    
    return object_index==argument0 || object_is_ancestor(object_index,argument0)


#define object_other_is_child_of
    ///object_other_is_child_of(object)
    //object: real - object to check
    //Checks if the other instance is a child of or the object itself.
    
    return other.object_index==argument0 || object_is_ancestor(other.object_index,argument0)


#define pick
    ///pick(which,opt1,opt2,...)
    //which: real - which option to return
    //Returns one of the arguments depending on the first argument.
    
    return argument[(argument[0] mod (argument_count-1))+1]


#define tile_find_anywhere
    ///tile_find_anywhere(x,y)
    //x: real - x coordinate
    //y: real - y coordinate
    //Finds a tile at the coordinate, regardless of layer depth.
    
    var __t;
    __t=tile_find(argument0,argument1,0)
    if (__t) return __t
    return tile_find(argument0,argument1,1)
//
//