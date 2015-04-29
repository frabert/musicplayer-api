unless require?
  window.mp = {}
  exports = window.mp
else
  exports = module.exports

requestAudio = (path, callback) ->
  request = new XMLHttpRequest
  # Async request
  request.open 'GET', path, true
  request.responseType = 'arraybuffer'
  request.onload = ->
    audioData = request.response
    callback audioData
  request.send()

class MusicTrack
  paused: false
  stopped: true
  soundStart: 0
  pauseOffset: 0

  constructor: (@player, @path, @onended, @onloaded) ->
    requestAudio @path, (audioData) =>
      @player.ctx.decodeAudioData audioData, (decodedData) =>
        @buffer = decodedData
        @onloaded()
        @initializeSource()

  initializeSource: ->
    @source = @player.ctx.createBufferSource()
    @source.connect @player.gainNode
    @source.buffer = @buffer
    @source.onended = @onended

  play: ->
    if !@paused and @stopped
      @soundStart = Date.now()
      @source.onended = @onended
      @source.start()
      @stopped = false
    else if @paused
      @paused = false
      @source.onended = @onended
      @source.start 0, @pauseOffset / 1000

  stop: ->
    unless @stopped
      @source.onended = null
      @source.stop()
      @stopped = true
      @paused = false
      @initializeSource()

  pause: ->
    unless @paused or @stopped
      @pauseOffset = Date.now() - @soundStart
      @paused = true
      @source.onended = null
      @source.stop()
      @initializeSource()

  getDuration: ->
    return @buffer.duration

  getPosition: ->
    if @paused
      return @pauseOffset / 1000
    else if @stopped
      return 0
    else
      return (Date.now() - @soundStart) / 1000

  setPosition: (position) ->
    if position < @buffer.duration
      if @paused
        @pauseOffset = position
      else if @stopped
        @stopped = false
        @soundStart = Date.now() - position * 1000
        @source.onended = @onended
        @source.start 0, position
      else
        @source.onended = null
        @source.stop()
        @initializeSource()
        @soundStart = Date.now() - position * 1000
        @source.start 0, position
    else
      throw new Error "Cannot play further the end of the track"

class MusicPlayer
  playlist: []
  muted: false

  ##############################################################################
  # Events                                                                     #
  ##############################################################################

  onSongFinished: (path) ->
    undefined

  onPlaylistEnded: ->
    undefined

  onPlayerStopped: ->
    undefined

  onPlayerPaused: ->
    undefined

  onTrackLoaded: (path) ->
    undefined

  onTrackAdded: (path) ->
    undefined

  onTrackRemoved: (path) ->
    undefined

  onVolumeChanged: (value) ->
    undefined

  onMuted: ->
    undefined

  onUnmuted: ->
    undefined

  constructor: ->
    @ctx = new (window.AudioContext or window.webkitAudioContext)
    @gainNode = @ctx.createGain()
    @gainNode.connect @ctx.destination

  setVolume: (value) ->
    @gainNode.gain.value = value
    @onVolumeChanged value

  getVolume: ->
    return @gainNode.gain.value

  toggleMute: ->
    if @muted
      @muted = false
      @gainNode.gain.value = @previousGain
      @onUnmuted()
    else
      @previousGain = @gainNode.gain.value
      @gainNode.gain.value = 0
      @muted = true
      @onMuted()

  pause: ->
    unless @playlist.length is 0
      @playlist[0].pause()
      @onPlayerPaused()

  stop: ->
    unless @playlist.length is 0
      @playlist[0].stop()
      @onPlayerStopped()

  play: ->
    unless @playlist.length is 0
      @playlist[0].play()

  playNext: ->
    unless @playlist.length is 0
      @playlist[0].stop()
      @playlist.shift()
      if @playlist.length is 0
        @onPlaylistEnded()
      else
        playlist[0].play()

  addTrack: (path) ->
    finishedCallback = =>
      @onSongFinished path
      @playNext()

    loadedCallback = =>
      @onTrackLoaded path

    @playlist.push new MusicTrack(this, path, finishedCallback, loadedCallback)

  insertTrack: (index, path) ->
    finishedCallback = =>
      @onSongFinished path
      @playNext()

    loadedCallback = =>
      @onTrackLoaded path

    @playlist.splice index, 0,
      new MusicTrack(this, path, finishedCallback, loadedCallback)

  removeTrack: (index) ->
    song = @playlist.splice index, 1
    @onTrackRemoved song.path

  replaceTrack: (index, path) ->
    finishedCallback = =>
      @onSongFinished path
      @playNext()

    loadedCallback = =>
      @onTrackLoaded path

    newTrack = new MusicTrack(this, path, finishedCallback, loadedCallback)
    oldTrack = @playlist.splice index, 1, newTrack
    @onTrackRemoved oldTrack.path

  getSongDuration: (index) ->
    if @playlist.length is 0
      return 0
    else
      if index?
        return playlist[index]?.getDuration()
      else
        return playlist[0].getDuration()

  getSongPosition: ->
    if @playlist.length is 0
      return 0
    else
      return @playlist[0].getPosition()

  setSongPosition: (value) ->
    unless @playlist.length is 0
      @playlist[0].setPosition value

  removeAllTracks: ->
    @stop()
    playlist = []

exports.MusicPlayer = MusicPlayer
