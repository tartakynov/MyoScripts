scriptId = 'com.thalmic.scripts.gmail'

-- Mappings
-- https://support.google.com/mail/answer/6594?hl=en
-- You need to do two things to get this working -
-- First, go to Settings and enable "Keyboard Shortcuts"
-- Second, go to Settings > Labs and enable the "Auto-advance" tool

-- Effects

function composeEmail()
    myo.keyboard("c", "press", "shift")
end

function archiveConversation()
    myo.keyboard("e", "press")
end

function replyToOne()
    myo.keyboard("r", "press")
end

function replyToAll()
    myo.keyboard("a", "press")
end

function deleteConversation()
    myo.keyboard("3", "press", "shift")
end

function nextOlderMessage()
    myo.keyboard("j", "press")
end

-- Helpers

function conditionallySwapWave(pose)
    if myo.getArm() == "left" then
        if pose == "waveIn" then
            pose = "waveOut"
        elseif pose == "waveOut" then
            pose = "waveIn"
        end
    end
    return pose
end

-- Unlock mechanism

function unlock()
    enabled = true
    extendUnlock()
end

function extendUnlock()
    enabledSince = myo.getTimeMilliseconds()
end


-- Triggers

function onPoseEdge(pose, edge)
    if pose == "thumbToPinky" then
        if edge == "off" then
            enabled = true
            enabledSince = myo.getTimeMilliseconds()
        elseif edge == "on" and not enabled then
            -- Vibrate twice on unlock
            myo.vibrate("short")
            myo.vibrate("short")
        end
    end

    if enabled and edge == "on" then
        pose = conditionallySwapWave(pose)

        if pose == "waveOut" then
            myo.vibrate("short")
            enabled = false
            replyToOne()
        end
        if pose == "waveIn" then
            myo.vibrate("short")
            enabled = false
            archiveConversation()
        end
        if pose == "fist" then
            myo.vibrate("short")
            enabled = false
            nextOlderMessage()
        end
        if pose == "fingersSpread" then
            myo.vibrate("medium")
            enabled = true
            replyToAll()
        end
    end
end

-- All timeouts in milliseconds
ENABLED_TIMEOUT = 2200
currentYaw = 0
currentPitch = 0

function onPeriodic()
    if enabled then

        if myo.getTimeMilliseconds() - enabledSince > ENABLED_TIMEOUT then
            enabled = false
        end
    end
end

function onForegroundWindowChange(app, title)
    --myo.debug(title)
    local wantActive = false
    activeApp = ""
    if platform == "MacOS" then
         wantActive = string.match(title, "Mail %- Google Chrome$") or
                     string.match(title, "^Inbox") or
                     string.match(title, "%- Gmail %- Google Chrome$")
        activeApp = "Gmail by Google"
    elseif platform == "Windows" then
        wantActive = string.match(title, "Mail %- Google Chrome$") or
                     string.match(title, "^Inbox") or
                     string.match(title, "%- Gmail %- Google Chrome$")
        activeApp = "Webmail"
    end
    return wantActive
end

function activeAppName()
    return activeApp
end

function onActiveChange(isActive)
    if not isActive then
        enabled = false
    end
end


