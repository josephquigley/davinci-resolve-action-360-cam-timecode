-- Tests for extract_timecode() in BatchUpdateTimecode-DJI-Insta360.lua
--
-- Run with:
--     lua test_extract_timecode.lua

dofile("BatchUpdateTimecode-DJI-Insta360.lua")

local cases = {
    -- DJI
    { "CAM_20260202095309_0008_D.mp4",     "095309", "DJI" },
    { "DJI_20260204215844_0026_D.mp4",     "215844", "DJI" },
    { "CAM_20260202095309_0008_D",         "095309", "DJI" },
    { "DJI_20260204215844_12345_D.mp4",    "215844", "DJI" },
    { "CAM_20260101000000_0001_D.mp4",     "000000", "DJI" },
    { "DJI_20260101235959_0099_D.mp4",     "235959", "DJI" },

    -- Insta360
    { "VID_20251130_104916_00_004.mp4",     "104916", "Insta360" },
    { "VID_20251130_133049_00_016_017.mp4", "133049", "Insta360" },
    { "VID_20251130_000000_00_001.mp4",     "000000", "Insta360" },

    -- Rejected
    { "random.mp4",                         nil, nil },
    { "",                                   nil, nil },
    { "CAM_20260202095309_0008_X.mp4",      nil, nil }, -- missing _D suffix
    { "CAM_2026020209530_0008_D.mp4",       nil, nil }, -- 13 digits, not 14
    { "vid_20251130_104916_00_004.mp4",     nil, nil }, -- lowercase prefix
    { "cam_20260202095309_0008_D.mp4",      nil, nil }, -- lowercase prefix
    { "VID_20251130104916_00_004.mp4",      nil, nil }, -- missing underscore between date and time
    { "VID_",                               nil, nil },
    { "CAM_",                               nil, nil },
}

local pass, fail = 0, 0
for _, c in ipairs(cases) do
    local input, want_t, want_s = c[1], c[2], c[3]
    local got_t, got_s = extract_timecode(input)
    if got_t == want_t and got_s == want_s then
        pass = pass + 1
    else
        fail = fail + 1
        print(string.format("FAIL: %q -> (%s, %s), want (%s, %s)",
            input, tostring(got_t), tostring(got_s),
            tostring(want_t), tostring(want_s)))
    end
end

print(string.format("%d passed, %d failed", pass, fail))
os.exit(fail == 0 and 0 or 1)
