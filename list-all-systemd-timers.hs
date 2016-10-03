#!/usr/bin/env runhaskell

{- Print all systemd timers, including system-wide and all user timers. -}

import System.Process
import System.Posix.User
import System.Posix.Types
import System.Exit

type Username  = String
data User      = Root | User { username :: Username
                             , uid :: Int
                             }
type Command   = String

main :: IO ()
main = do
  uid <- getRealUserID
  if uid == CUid 0
  then listTimers
  else do
    putStrLn "Sorry, not root user.\n\
               \Please use sudo or su to become \
               \root user before running this script."
    exitFailure

listTimers :: IO ()
listTimers = do
  putStrLn "System timers:"
  callCommand $ createListTimersCommandString Root
  mapM_ (\x -> do
    putStrLn $ "\nTimers for " ++ (username x) ++ ":"
    callCommand $ createListTimersCommandString x
    ) =<< getDbusUserList

createListTimersCommandString :: User -> Command
createListTimersCommandString Root  = "systemctl --no-pager list-timers"
createListTimersCommandString (User name uid) =
  "su " ++ name 
  ++ " -c 'XDG_RUNTIME_DIR=/run/user/" ++ (show uid)
  ++ " systemctl --no-pager --user list-timers'"

-- This is intended to get every 'User' who has an active dbus daemon running.
getDbusUserList :: IO [User]
getDbusUserList = do
  uids <- uidsWithRunningDbusDaemon
  mapM (\x -> do
    e <- getUserEntryForID $ toEnum  x
    pure $ User (userName e) x
    ) uids

uidsWithRunningDbusDaemon :: IO [Int]
uidsWithRunningDbusDaemon = do
  o <- readProcess 
    "systemctl"
    ["--no-legend", "--full", "list-units", "--state=active", "user@*.service"]
    ""
  pure $ parseSystemctlOutputForUIDs o

parseSystemctlOutputForUIDs :: String -> [Int]
parseSystemctlOutputForUIDs s = (read . p) <$> lines s
  where
    p :: String -> String
    p ('@':xs)  = p' xs
    p (_:xs)    = p xs
    p' :: String -> String
    p' ('.':xs)   = ""
    p' (x:xs)   = x:(p' xs)
