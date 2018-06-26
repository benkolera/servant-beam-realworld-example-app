module RealWorld.Conduit.Spec.Database
  ( withConnection
  ) where

import Control.Applicative (pure)
import Control.Exception (bracket)
import Data.ByteString.Char8 (pack)
import Data.Functor ((<$>))
import Database.PostgreSQL.Simple (Connection, begin, close, rollback)
import RealWorld.Conduit.Database (openConduitDb)
import RealWorld.Conduit.Options (Options(Options, databaseUrl, port))
import System.Environment (getEnv)
import System.IO (IO)

withConnection :: (Connection -> IO a) -> IO a
withConnection = bracket openConnection closeConnection
  where
    openConnection = do
      databaseUrl <- pack <$> getEnv "DATABASE_URL"
      conn <- openConduitDb (Options {databaseUrl, port = 5000})
      begin conn
      pure conn
    closeConnection conn = do
      rollback conn
      close conn
