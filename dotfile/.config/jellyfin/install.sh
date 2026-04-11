#!/bin/sh

set -x

jellyfin_server="http://localhost:8096"
username="jellyfin"
password="jellyfin"
storage_path="/home/library"
log_file="/tmp/jellyfin-init.log"

{
  echo "Waiting for Jellyfin to start listening on port 8096..."
  while ! curl -s --max-time 5 --fail "${jellyfin_server}/health" > /dev/null; do
      sleep 1
  done
  echo "Jellyfin is now listening on port 8096"

  curl "${jellyfin_server}/Startup/Configuration" \
    -H 'Content-Type: application/json' \
    --data-raw '{"UICulture":"en-US","MetadataCountryCode":"US","PreferredMetadataLanguage":"en"}' \
    -vv
  curl "${jellyfin_server}/Startup/User" \
    -vv
  curl "${jellyfin_server}/Startup/User" \
    -H 'Content-Type: application/json' \
    --data-raw '{"Name":"'${username}'","Password":"'${password}'"}' \
    -vv
  curl "${jellyfin_server}/Library/VirtualFolders?collectionType=music&refreshLibrary=false&name=Music" \
    -H 'Content-Type: application/json' \
    --data-raw '{"LibraryOptions":{"EnableArchiveMediaFiles":false,"EnablePhotos":true,"EnableRealtimeMonitor":true,"ExtractChapterImagesDuringLibraryScan":false,"EnableChapterImageExtraction":false,"DownloadImagesInAdvance":false,"EnableInternetProviders":true,"ImportMissingEpisodes":false,"SaveLocalMetadata":false,"EnableAutomaticSeriesGrouping":false,"PreferredMetadataLanguage":"","MetadataCountryCode":"","SeasonZeroDisplayName":"Specials","AutomaticRefreshIntervalDays":0,"EnableEmbeddedTitles":false,"EnableEmbeddedEpisodeInfos":false,"SkipSubtitlesIfEmbeddedSubtitlesPresent":false,"SkipSubtitlesIfAudioTrackMatches":false,"SaveSubtitlesWithMedia":true,"RequirePerfectSubtitleMatch":true,"MetadataSavers":[],"TypeOptions":[{"Type":"MusicArtist","MetadataFetchers":["MusicBrainz"],"MetadataFetcherOrder":["MusicBrainz","TheAudioDB"]},{"Type":"MusicAlbum","MetadataFetchers":["MusicBrainz"],"MetadataFetcherOrder":["MusicBrainz","TheAudioDB"]},{"Type":"MusicVideo","MetadataFetchers":["TheMovieDb"],"MetadataFetcherOrder":["TheMovieDb"],"ImageFetchers":["TheMovieDb","Screen Grabber"],"ImageFetcherOrder":["TheMovieDb","Screen Grabber"]},{"Type":"Audio","ImageFetchers":["Image Extractor"],"ImageFetcherOrder":["Image Extractor"]}],"LocalMetadataReaderOrder":["Nfo"],"SubtitleDownloadLanguages":[],"DisabledSubtitleFetchers":[],"SubtitleFetcherOrder":[],"PathInfos":[{"Path":"'"${storage_path}"'/Music"}]}}' \
    -vv
  curl "${jellyfin_server}/Library/VirtualFolders?collectionType=movies&refreshLibrary=false&name=Movies" \
    -H 'Content-Type: application/json' \
    --data-raw '{"LibraryOptions":{"EnableArchiveMediaFiles":false,"EnablePhotos":true,"EnableRealtimeMonitor":true,"ExtractChapterImagesDuringLibraryScan":false,"EnableChapterImageExtraction":false,"DownloadImagesInAdvance":false,"EnableInternetProviders":true,"ImportMissingEpisodes":false,"SaveLocalMetadata":false,"EnableAutomaticSeriesGrouping":false,"PreferredMetadataLanguage":"","MetadataCountryCode":"","SeasonZeroDisplayName":"Specials","AutomaticRefreshIntervalDays":0,"EnableEmbeddedTitles":false,"EnableEmbeddedEpisodeInfos":false,"SkipSubtitlesIfEmbeddedSubtitlesPresent":false,"SkipSubtitlesIfAudioTrackMatches":false,"SaveSubtitlesWithMedia":true,"RequirePerfectSubtitleMatch":true,"MetadataSavers":[],"TypeOptions":[{"Type":"Movie","MetadataFetchers":["TheMovieDb","The Open Movie Database"],"MetadataFetcherOrder":["TheMovieDb","The Open Movie Database"],"ImageFetchers":["TheMovieDb","The Open Movie Database","Screen Grabber"],"ImageFetcherOrder":["TheMovieDb","The Open Movie Database","Screen Grabber"]}],"LocalMetadataReaderOrder":["Nfo"],"SubtitleDownloadLanguages":[],"DisabledSubtitleFetchers":[],"SubtitleFetcherOrder":[],"PathInfos":[{"Path":"'"${storage_path}"'/Movies"}]}}' \
    -vv
  curl "${jellyfin_server}/Library/VirtualFolders?collectionType=tvshows&refreshLibrary=false&name=TV%20Shows" \
    -H 'Content-Type: application/json' \
    --data-raw '{"LibraryOptions":{"EnableArchiveMediaFiles":false,"EnablePhotos":true,"EnableRealtimeMonitor":true,"ExtractChapterImagesDuringLibraryScan":false,"EnableChapterImageExtraction":false,"DownloadImagesInAdvance":false,"EnableInternetProviders":true,"ImportMissingEpisodes":false,"SaveLocalMetadata":false,"EnableAutomaticSeriesGrouping":false,"PreferredMetadataLanguage":"","MetadataCountryCode":"","SeasonZeroDisplayName":"Specials","AutomaticRefreshIntervalDays":0,"EnableEmbeddedTitles":false,"EnableEmbeddedEpisodeInfos":false,"SkipSubtitlesIfEmbeddedSubtitlesPresent":false,"SkipSubtitlesIfAudioTrackMatches":false,"SaveSubtitlesWithMedia":true,"RequirePerfectSubtitleMatch":true,"MetadataSavers":[],"TypeOptions":[{"Type":"Series","MetadataFetchers":["TheTVDB","The Open Movie Database"],"MetadataFetcherOrder":["TheTVDB","TheMovieDb","The Open Movie Database"],"ImageFetchers":["TheTVDB"],"ImageFetcherOrder":["TheTVDB","TheMovieDb"]},{"Type":"Season","MetadataFetchers":[],"MetadataFetcherOrder":["TheMovieDb"],"ImageFetchers":["TheTVDB","TheMovieDb"],"ImageFetcherOrder":["TheTVDB","TheMovieDb"]},{"Type":"Episode","MetadataFetchers":["TheTVDB"],"MetadataFetcherOrder":["TheTVDB","TheMovieDb","The Open Movie Database"],"ImageFetchers":["TheTVDB","Screen Grabber"],"ImageFetcherOrder":["TheTVDB","TheMovieDb","The Open Movie Database","Screen Grabber"]}],"LocalMetadataReaderOrder":["Nfo"],"SubtitleDownloadLanguages":[],"DisabledSubtitleFetchers":[],"SubtitleFetcherOrder":[],"PathInfos":[{"Path":"'"${storage_path}"'/TVShows"}]}}' \
    -vv
  curl "${jellyfin_server}/Library/VirtualFolders?collectionType=homevideos&refreshLibrary=false&name=Photos" \
    -H 'Content-Type: application/json' \
    --data-raw '{"LibraryOptions":{"EnableArchiveMediaFiles":false,"EnablePhotos":true,"EnableRealtimeMonitor":true,"ExtractChapterImagesDuringLibraryScan":false,"EnableChapterImageExtraction":false,"DownloadImagesInAdvance":false,"EnableInternetProviders":true,"ImportMissingEpisodes":false,"SaveLocalMetadata":false,"EnableAutomaticSeriesGrouping":false,"PreferredMetadataLanguage":"","MetadataCountryCode":"","SeasonZeroDisplayName":"Specials","AutomaticRefreshIntervalDays":0,"EnableEmbeddedTitles":false,"EnableEmbeddedEpisodeInfos":false,"SkipSubtitlesIfEmbeddedSubtitlesPresent":false,"SkipSubtitlesIfAudioTrackMatches":false,"SaveSubtitlesWithMedia":true,"RequirePerfectSubtitleMatch":true,"MetadataSavers":[],"TypeOptions":[{"Type":"Video","ImageFetchers":["Screen Grabber"],"ImageFetcherOrder":["Screen Grabber"]}],"LocalMetadataReaderOrder":["Nfo"],"SubtitleDownloadLanguages":[],"DisabledSubtitleFetchers":[],"SubtitleFetcherOrder":[],"PathInfos":[{"Path":"'"${storage_path}"'/Photos"}]}}' \
    -vv
  curl "${jellyfin_server}/Startup/Configuration" \
    -H 'Content-Type: application/json' \
    --data-raw '{"UICulture":"en-US","MetadataCountryCode":"US","PreferredMetadataLanguage":"en"}' \
    -vv
  curl "${jellyfin_server}/Startup/RemoteAccess" \
    -H 'Content-Type: application/json' \
    --data-raw '{"EnableRemoteAccess":true,"EnableAutomaticPortMapping":false}' \
    -vv
  curl "${jellyfin_server}/Startup/Complete" \
    -X 'POST' \
    -vv
} 2>&1 | tee "${log_file}"

