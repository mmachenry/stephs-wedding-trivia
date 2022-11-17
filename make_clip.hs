import System.Environment (getArgs)
import System.Process (readProcess, callProcess)
import System.Directory (doesFileExist)
import Data.String.Utils (strip)
import ClassyPrelude (unlessM)

main = do
  [url, start, end] <- getArgs
  youtubeFile <- fmap strip $ readProcess "youtube-dl" ["-x", "--get-filename", url] ""
  unlessM (doesFileExist youtubeFile)
    (callProcess "youtube-dl" ["-x", url])
  let outFile = "clip_" ++ youtubeFile
  let tmpFile = "tmp_" ++ youtubeFile
  callProcess "ffmpeg" ["-ss", start, "-to", end, "-i", youtubeFile, "-c", "copy", tmpFile]
  duration <- fmap strip $ readProcess "ffprobe" ["-v", "error", "-show_entries", "format=duration", "-of", "default=noprint_wrappers=1:nokey=1", tmpFile] ""
  let fadeStart = show ((read duration) - 1.0)
  callProcess "ffmpeg" ["-i", tmpFile, "-af", "afade=t=out:st=" ++ fadeStart ++ ":d=1", outFile]
  putStrLn outFile
