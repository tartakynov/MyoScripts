scriptId = 'com.thalmic.scripts.gslides'
minMyoConnectVersion = '0.7.0'
scriptTitle = 'Google Slides Connector'


-- Wave Left to previous slide
-- Wave Right to next slide

function nextSlide()
    myo.keyboard("right_arrow", "press")
end

function prevSlide()
    myo.keyboard("left_arrow", "press")
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
                prevSlide()
            else
                nextSlide()
            end
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
            app == "org.mozilla.firefox") and string.find(title, "Google") then
            return true
        end
    elseif platform == "Windows" then
        if (app == "Safari.exe" or
            app == "chrome.exe" or
            app == "firefox.exe" or
            app == "iexplore.exe") and string.find(title, "Google") then
            return true
        end
    end
end

function activeAppName()
    return "Google Slides"
end
