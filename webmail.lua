scriptId = 'com.thalmic.scripts.gmail'

-- Mappings
-- https://support.google.com/mail/answer/6594?hl=en
-- You need to do two things to get this working -
-- First, go to Settings and enable "Keyboard Shortcuts"
-- Second, go to Settings > Labs and enable the "Auto-advance" tool

-- Wave Left to Archive
-- Wave Right to Reply
-- Fist to go to next message
-- Spread Fingers and release up to go back to conversation
-- Spread Fingers and release down to reply all

-- Effects

function composeEmail()
    myo.keyboard("c", "press")
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

function conversationScreen()
    myo.keyboard("u", "press")
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
        -- Pitch... 0.30750495195389
        -- Yaw... 2.7852053642273
        --myo.debug("Pitch... "..currentPitch)
        --myo.debug("Yaw... "..currentYaw)
        -- myo.debug("Roll... "..currentRoll)
        if edge == "off" then
            enabled = true
            enabledSince = myo.getTimeMilliseconds()
        elseif edge == "on" and not enabled then
            -- Vibrate twice on unlock
            myo.vibrate("short")
            myo.vibrate("short")
        end
    end

    if enabled then
    --if enabled and edge == "on" then
        pose = conditionallySwapWave(pose)

        if pose == "waveOut" and edge == "on" then
            myo.vibrate("short")
            enabled = false
            replyToOne()
        end
        if pose == "waveIn" and edge == "on" then
            if currentYaw > 1.5 then
               -- myo.debug('great than 1.5 '..currentYaw)
            else
                --myo.debug('less than 1.5 '..currentYaw)
            end
            myo.vibrate("short")
            enabled = false
            archiveConversation()
        end
        if pose == "fist" and edge == "on" then
            myo.vibrate("short")
            enabled = false
            nextOlderMessage()
        end
        if pose == "fingersSpread" then
           -- myo.debug("hey.. "..currentYaw)
            if edge == "off" and currentPitch < 0.1 then
                myo.vibrate("medium")
                enabled = true
                replyToAll()
            elseif edge == "off" and currentPitch > 0.2 then
                myo.vibrate("short")
                enabled = true
                conversationScreen()
            end
        end
    end
end

-- All timeouts in milliseconds
ENABLED_TIMEOUT = 2200
currentYaw = 0
currentPitch = 0
currentRoll = 0

function onPeriodic()
    currentYaw = myo.getYaw()
    currentPitch = myo.getPitch()
    currentRoll = myo.getRoll()
    
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


