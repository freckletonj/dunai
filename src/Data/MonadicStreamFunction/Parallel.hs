module Data.MonadicStreamFunction.Parallel where

-- External
import Control.Arrow
import GHC.Conc

-- Internal
import Data.MonadicStreamFunction

-- | Run two MSFs in parallel, taking advantage of parallelism if
--   possible. This is the parallel version of '(***)'.


(*|*) :: Monad m => MSF m a b -> MSF m c d -> MSF m (a, c) (b, d)
msf1 *|* msf2 = MSF $ \(a, c) -> do
  (b, msf1') <- unMSF msf1 a
  (d, msf2') <- unMSF msf2 c
  b `par` d `pseq` return ((b, d), msf1' *|* msf2')

-- | Parallel version of '(&&&)'.
(&|&) :: Monad m => MSF m a b -> MSF m a c -> MSF m a (b, c)
msf1 &|& msf2 = arr (\a -> (a, a)) >>> (msf1 *|* msf2)
