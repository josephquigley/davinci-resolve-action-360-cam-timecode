-- DaVinci Resolve Timecode Setter for Insta360 and DJI cameras
-- Extracts HH:MM:SS from filename and sets as timecode.
--
-- Supported filename patterns:
--   Insta360: VID_YYYYMMDD_HHMMSS_XX_YYY.mp4
--   DJI:      CAM_YYYYMMDDHHMMSS_NNNN_D.mp4
--             DJI_YYYYMMDDHHMMSS_NNNN_D.mp4

local function extract_timecode(clip_name)
    if not clip_name then return nil end

    -- DJI: CAM_20260202095309_0008_D or DJI_20260204215844_0026_D
    for _, prefix in ipairs({ "CAM", "DJI" }) do
        local t = string.match(clip_name,
            "^" .. prefix .. "_%d%d%d%d%d%d%d%d(%d%d%d%d%d%d)_%d+_D")
        if t then return t, "DJI" end
    end

    -- Insta360: VID_YYYYMMDD_HHMMSS_XX_YYY
    local t = string.match(clip_name,
        "^VID_%d%d%d%d%d%d%d%d_(%d%d%d%d%d%d)_")
    if t then return t, "Insta360" end

    return nil
end

local function main()
    local resolve = Resolve()
    if not resolve then
        print("ERROR: Could not connect to DaVinci Resolve")
        print("Make sure DaVinci Resolve is running")
        return
    end

    local projectManager = resolve:GetProjectManager()
    local currentProject = projectManager:GetCurrentProject()

    if not currentProject then
        print("ERROR: No project is currently open")
        return
    end

    local mediaPool = currentProject:GetMediaPool()
    local clips = mediaPool:GetSelectedClips()

    if not clips or #clips == 0 then
        print("⚠ ERROR: No clips selected in Media Pool")
        print("Please select one or more clips and run the script again.")
        return
    end

    print(string.format("Found %d selected clip(s)", #clips))
    print(string.rep("-", 60))

    local success_count = 0
    local failed_count = 0

    for _, clip in ipairs(clips) do
        local clip_name = clip:GetClipProperty("File Name")
        local time_str, source = extract_timecode(clip_name)

        if not time_str then
            print(string.format("⚠ SKIPPED: %s", clip_name or "<unknown>"))
            print(" Filename does not match Insta360 or DJI pattern")
            failed_count = failed_count + 1
        else
            local hours   = time_str:sub(1, 2)
            local minutes = time_str:sub(3, 4)
            local seconds = time_str:sub(5, 6)
            local new_timecode = string.format("%s:%s:%s:00", hours, minutes, seconds)

            local ok = clip:SetClipProperty("Start TC", new_timecode)
            if ok then
                print(string.format("✓ SUCCESS [%s]: %s", source, clip_name))
                print(string.format(" Extracted Time: %s → %s", time_str, new_timecode))
                success_count = success_count + 1
            else
                print(string.format("✗ FAILED: %s - SetClipProperty returned False", clip_name))
                failed_count = failed_count + 1
            end
        end
    end

    print(string.rep("-", 60))
    print("Processing complete:")
    print(string.format(" Success: %d", success_count))
    print(string.format(" Failed: %d", failed_count))
    print(string.format(" Total: %d", #clips))
end

-- Expose for testing; harmless when DaVinci runs the script.
_G.extract_timecode = extract_timecode

-- Run main() only inside DaVinci Resolve, where Resolve() is defined.
-- This keeps the parser importable from plain Lua test runners.
if type(_G.Resolve) == "function" then
    main()
end
