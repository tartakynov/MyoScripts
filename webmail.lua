scriptId = 'com.thalmic.scripts.gmail'
minMyoConnectVersion = '0.7.0'
scriptDetailsUrl = 'https://market.myo.com/app//547cdbbae4b06d0c583f4336'
scriptTitle = 'Gmail Connector'


-- Mappings
-- https://support.google.com/mail/answer/6594?hl=en
-- You need to do two things to get this working -
-- First, go to Settings and enable "Keyboard Shortcuts"
-- Second, go to Settings > Labs and enable the "Auto-advance" tool

-- Wave Left to Archive
-- Wave Right to Reply All
-- Fist to go to next message
-- Sp

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

-- Triggers

function onPoseEdge(pose, edge)
     if pose == "waveIn" or pose == "waveOut" then
        if edge == "on" then
            pose = conditionallySwapWave(pose)
            if pose == "waveIn" then
                archiveConversation()
            else
                replyToAll()
            end
            -- Extend unlock and notify user
            myo.unlock("timed")
            myo.notifyUserAction()
        end
    end
    if pose == "fist" then
        if edge == "on" then
            nextOlderMessage()
            -- Extend unlock and notify user
            myo.unlock("timed")
            myo.notifyUserAction()
        end
    end
    if pose == "fingersSpread" then
        if edge == "off" then
            conversationScreen()
            -- Extend unlock and notify user
            myo.unlock("timed")
            myo.notifyUserAction()
        end
    end
end

function onForegroundWindowChange(app, title)
    if platform == "MacOS" then
        if (app == "com.apple.Safari" or
            app == "com.google.Chrome" or
            app == "org.mozilla.firefox") and
                (string.match(title, "Mail %- Google Chrome$") or
                string.match(title, "^Inbox") or
                string.match(title, "%- Gmail %- Google Chrome$")) then
            return true
        end
    elseif platform == "Windows" then
        if (app == "Safari.exe" or
            app == "chrome.exe" or
            app == "firefox.exe" or
            app == "iexplore.exe") and
                (string.match(title, "Mail %- Google Chrome$") or
                string.match(title, "^Inbox") or
                string.match(title, "%- Gmail %- Google Chrome$")) then
            return true
        end
    end
end

function activeAppName()
    return "Gmail"
end
