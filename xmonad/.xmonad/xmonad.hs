import XMonad

import XMonad.Layout.Spacing
import XMonad.Actions.GridSelect
import XMonad.Util.EZConfig (additionalKeysP, mkNamedKeymap)
import XMonad.Util.Loggers
import XMonad.Util.NamedActions
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.EwmhDesktops



myModMask = mod4Mask 
myTerminal = "alacritty"
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#f5ef42"
myBorderWidth   = 2

mySpacing = spacingRaw False            -- False=Apply even when single window
                       (Border 5 5 5 5) -- Screen border size top bot rght lft
                       True             -- Enable screen border
                       (Border 5 5 5 5) -- Window border size
                       True             -- Enable window bordersmain :: IO ()

myLayout = mySpacing $ avoidStruts $ tiled ||| Mirror tiled ||| Full
  where
     tiled   = Tall nmaster delta ratio
     nmaster = 1
     ratio   = 1/2
     delta   = 3/100


myFont :: String
-- myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=13:antialias=true:hinting=true"
myFont = "xft:Fira Mono:pixelsize=15:antialias=true:hinting=true"

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 40
                   , gs_cellwidth    = 180
                   , gs_cellpadding  = 6
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont
                   }

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp" --> doFloat
    , isDialog            --> doFloat
    ]

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = magenta " • "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2
    , ppHidden          = white . wrap " " ""
    , ppHiddenNoWindows = lowWhite . wrap " " ""
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused   = wrap (white    "[") (white    "]") . magenta . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . blue    . ppWindow

    -- | Windows should have *some* title, which should not not exceed a
    -- sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

    blue, lowWhite, magenta, red, white, yellow :: String -> String
    magenta  = xmobarColor "#ff79c6" ""
    blue     = xmobarColor "#bd93f9" ""
    white    = xmobarColor "#f8f8f2" ""
    yellow   = xmobarColor "#f1fa8c" ""
    red      = xmobarColor "#ff5555" ""
    lowWhite = xmobarColor "#bbbbbb" ""

myKeysBinding = 
          [("M-p p", spawn "dmenu_run")             -- launch dmenu
          ,("M-S-p", spawn "gmrun")                 -- launch gmrun
          ,("M-p e", spawn "lanu-confedit")         -- launch script in ~/my-scripts/
          ,("M-p w", spawn "lanu-wifi")             -- launch script in ~/my-scripts/
          ,("M-v h", spawn "pactl set-sink-volume @DEFAULT_SINK@ 150%") 
          ,("<XF86AudioMute>", spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
          ,("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
          ,("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
          ,("<XF86MonBrightnessUp>", spawn "lux -a 10%")
          ,("<XF86MonBrightnessDown>", spawn "lux -s 10%")

          ,("M-S-t", spawnSelected'                 -- launch GridSelect
            [ ("Firefox", "firefox")
            , ("Chrome", "google-chrome-stable")
            , ("Blueman", "blueman-manager")
            , ("Nautilus", "nautilus")
            , ("Pavucontrol", "pavucontrol")
            , ("Postman", "~/postman/postman-9.18.3-linux-x64/Postman/Postman")
            , ("Idea", "~/idea/idea-IU-221.5080.210/bin/idea.sh")
            , ("Nitrogen", "nitrogen")
            , ("Gimp", "gimp")
            , ("VLC player", "vlc")
            , ("Nvim", (myTerminal ++ " -e nvim"))
            , ("FBReader", "FBReader")])
          ,("C-<Print>", spawn "sleep 0.2; scrot -s") -- Print selected window (should be select after keys pressed)
          ,("<Print>", spawn "scrot")                 -- Print whole screen
          ]

defaults = def
    {  
        terminal           = myTerminal,
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        modMask            = myModMask,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        borderWidth        = myBorderWidth
    }
    `additionalKeysP` myKeysBinding

main :: IO ()
main = xmonad
     . ewmhFullscreen
     . ewmh
     . withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) defToggleStrutsKey
     $ docks defaults

