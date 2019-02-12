{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeFamilies #-}

module Client where

import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.Reader
import qualified Data.ByteString as BS
import Network.Datagram as D
import Network.Socket as N

send host port dgram = do
  let hints = defaultHints {addrSocketType = N.Datagram}
  addr:_ <- getAddrInfo (Just hints) (Just host) (Just port)
  sock <- socket (addrFamily addr) (addrSocketType addr) (addrProtocol addr)
  D.runUdpT1024 (c addr dgram) sock
  where
    c addr dgram = do
      D.connect $ addrAddress addr
      flip D.send dgram $ addrAddress addr
      D.close
