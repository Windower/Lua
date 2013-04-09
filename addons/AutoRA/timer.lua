--[[

    This file is based on the timer.lua script which can be found within the 
    popular game, Garry's Mod. However there are no credits attached to the 
    file so the original author of this file is unknown. 

    It has been modified by Banggugyangu. 

]]--

-- Module Definition..
module( "timer", package.seeall );

----------------------------------------------------------------------
-- Timer Status Definitions
----------------------------------------------------------------------
local TIMER_PAUSED      = 0;
local TIMER_STOPPED     = 1;
local TIMER_RUNNING     = 2;

----------------------------------------------------------------------
-- Timer Table Definitions
----------------------------------------------------------------------
local Timer         = { };
local TimerOnce     = { };

----------------------------------------------------------------------
-- func : CreateTimer
-- desc : Creates a timer that is started in a 'stopped' state.
----------------------------------------------------------------------
local function CreateTimer( name )
    if (Timer[ name ] == nil) then
        Timer[ name ] = { };
        Timer[ name ].Status = TIMER_STOPPED;
        return true;
    end
    return false;
end

----------------------------------------------------------------------
-- func : RemoveTimer
-- desc : Removes a timer.
----------------------------------------------------------------------
function RemoveTimer( name )
    Timer[ name ] = nil;
end

----------------------------------------------------------------------
-- func : IsTimer
-- desc : Determines if a timer with the given name exists.
----------------------------------------------------------------------
function IsTimer( name )
    return Timer[ name ] ~= nil;
end

----------------------------------------------------------------------
-- func : Once
-- desc : Creates a one-time timer.
----------------------------------------------------------------------
function Once( delay, func, ... )
    local once_timer  = { };
    once_timer.Finish = os.time() + delay;
    if (func) then once_timer.Function = func; end
    once_timer.Args = {...};
    
    table.insert( TimerOnce, once_timer );
    return true;
end

----------------------------------------------------------------------
-- func : Create
-- desc : Creates a timer.
----------------------------------------------------------------------
function Create( name, delay, reps, func, ... )
    -- Remove existing timer..
    if (IsTimer( name )) then
        RemoveTimer( name );
    end
    
    -- Adjust and start the timer..
    AdjustTimer( name, delay, reps, func, unpack( {...} ) );
    StartTimer( name );
end

----------------------------------------------------------------------
-- func : StartTimer
-- desc : Starts, or restarts, the timer.
----------------------------------------------------------------------
function StartTimer( name )
    if (IsTimer( name )) then
        Timer[ name ].n         = 0;
        Timer[ name ].Status    = TIMER_RUNNING;
        Timer[ name ].Last      = os.time();
        return true;
    end
    return false;
end

----------------------------------------------------------------------
-- func : AdjustTimer
-- desc : Updates a timers params.
----------------------------------------------------------------------
function AdjustTimer( name, delay, reps, func, ... )
    -- Recreate the timer..
    CreateTimer( name );
    
    -- Set timer properties..
    Timer[ name ].Delay = delay;
    Timer[ name ].Reps  = reps;
    Timer[ name ].Args  = {...};
    
    if (func) then
        Timer[ name ].Function = func;
    end
    
    return true;
end

----------------------------------------------------------------------
-- func : Pause
-- desc : Pauses a timer.
----------------------------------------------------------------------
function Pause( name )
    if (IsTimer( name )) then
        if (Timer[ name ].Status == TIMER_RUNNING) then
            Timer[ name ].Diff      = os.time() - Timer[ name ].Last;
            Timer[ name ].Status    = TIMER_PAUSED;
            return true;
        end
    end
    return false;
end

----------------------------------------------------------------------
-- func : Unpause
-- desc : Unpauses a timer.
----------------------------------------------------------------------
function Unpause( name )
    if (IsTimer( name )) then
        if (Timer[ name ].Status == TIMER_RUNNING) then
            Timer[ name ].Diff      = nil;
            Timer[ name ].Status    = TIMER_RUNNING;
            return true;
        end
    end
    return false;
end

----------------------------------------------------------------------
-- func : Toggle
-- desc : Toggles a timers status.
----------------------------------------------------------------------
function Toggle( name )
    if (IsTimer( name )) then
        if (Timer[ name ].Status == TIMER_PAUSED) then
            return Unpause( name );
        elseif (Timer[ name ].Status == TIMER_RUNNING) then
            return Pause( name );
        end
    end
    return false;
end

----------------------------------------------------------------------
-- func : Stop
-- desc : Stops a timer.
----------------------------------------------------------------------
function Stop( name )
    if (IsTimer( name )) then
        Timer[ name ].Status = TIMER_STOPPED;
        return true;
    end
    return false;
end
