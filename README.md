# musicplayer-api
**musicplayer-api** provides a simple way to implement a gapless music player using Web Audio API. It was originally meant to be used in environments such as [electron](https://github.com/atom/electron) but may eventually work in a browser.

Add it to your package with
```
npm install musicplayer-api
```

## Example of usage
```coffeescript
MusicPlayer = require('musicplayer-api').MusicPlayer

# The constructor automatically creates a new AudioContext
# and GainNode
player = new MusicPlayer()

# The addTrack is responsible of inserting songs in the
# playlist. It also asynchronously loads songs into memory
player.addTrack 'mymusic1.mp3'
player.addTrack 'mywav.wav'

player.play()
```

## API Documentation
When used in node, *musicplayer-api* exports an object containing the `MusicPlayer` class. The same object is set to the `mp` global if used in a browser.

### MusicPlayer class
#### Methods
```coffeescript
player.setVolume( value )
```
Sets the volume to the specified value, where 0 is muted and 1 is default playback intensity.

```coffeescript
player.getVolume()
```
Returns the playback intensity. Normally is 1.

```coffeescript
player.toggleMuted()
```
Toggles between muted and unmuted state.

```coffeescript
player.play()
```
Starts playing or resumes the playback of the current playlist.

```coffeescript
player.stop()
```
Stops playing the current song in the playlist. When `play` is called again, the song is restarted from the beginning.

```coffeescript
player.pause()
```
Suspends the playback of the current song.

```coffeescript
player.playNext()
```
Skips to the next song in the playlist.

```coffeescript
player.addTrack( path )
```
Adds the specified song to the playlist.

```coffeescript
player.insertTrack( index, path )
```
Adds the specified song in the specified position of the playlist.

```coffeescript
player.removeTrack( index )
```
Removes the specified song from the playlist.

```coffeescript
player.removeAllTracks()
```
Clears the playlist and stops the playback.

#### Events
##### onSongFinished
Called when a song has reached the end.

*NOTE:* Passes the song's path as an argument.
##### onPlaylistEnded
Called when the playlist has reached the end.
##### onPlayerStopeed
Called when the player is stopped programmatically.
##### onPlayerPaused
Called when the player is paused programmatically.
##### onTrackAdded
Called when a track is added to the playlist.

*NOTE:* Passes the track's path as an argument.
##### onTrackRemoved
Called when a track is removed from the playlist.

*NOTE:* Passes the track's path as an argument.
##### onVolumeChanged
Called when the volume is changed programmatically.

*NOTE:* Passes the volume's value as an argument.
##### onMuted
Called when the player is muted programmatically.
##### onUnmuted
Called when the player is unmuted programmatically.

#### Example
```coffeescript
player = new MusicPlayer()
player.onVolumeChanged = (value) =>
  console.log 'Current volume: ' + value.toString()
```
