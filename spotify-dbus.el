;;; spotify-dbus --- Dbus-specific code for Spotify.el

;;; Commentary:

;; Somehow shuffeling, setting volume and loop status work not as expected.
;; Quering the attribute does not return the expected value and setting it
;; has no effect.
;; The dbus interface of spotify seems to be broken.
;; Play does not have an effect.

;;; Code:
(defun spotify-dbus-call (method &rest args)
  "Call METHOD with optional ARGS via D-Bus on the Spotify service."
    (apply 'dbus-call-method-asynchronously :session
				     "org.mpris.MediaPlayer2.spotify"
				     "/org/mpris/MediaPlayer2"
				     "org.mpris.MediaPlayer2.Player"
				     method
				     nil args))

(defun spotify-dbus-get-property (property)
  "Get value of PROPERTY via D-Bus on the Spotify service."
  (dbus-get-property :session
		     "org.mpris.MediaPlayer2.spotify"
		     "/org/mpris/MediaPlayer2"
		     "org.mpris.MediaPlayer2.Player"
		     property))

(defun spotify-dbus-set-property (property value)
  "Set PROPERTY to VALUE via D-Bus on the Spotify service."
  (dbus-set-property :session
		     "org.mpris.MediaPlayer2.spotify"
		     "/org/mpris/MediaPlayer2"
		     "org.mpris.MediaPlayer2.Player"
		     property
		     value))

(defun spotify-dbus-player-toggle-play ()
  "Toggle Play/Pause."
  (spotify-dbus-call "PlayPause"))

(defun spotify-dbus-player-next-track ()
  "Play next track."
  (spotify-dbus-call "Next"))

(defun spotify-dbus-player-previous-track ()
  "Play previous previous."
  (spotify-dbus-call "Previous"))

(defun spotify-dbus-toggle-repeat ()
  "Toggle loop options.

Does nothing.  Spotify client broken."
  (if (spotify-dbus-repeating-p)
      (spotify-dbus-set-property "LoopStatus" nil)
    (spotify-dbus-set-property "LoopStatus" "Playlist")))

(defun spotify-dbus-toggle-shuffle ()
  "Toggle shuffle.

Does nothing.  Spotify client broken."
  (if (spotify-dbus-shuffling-p)
      (spotify-dbus-set-property "Shuffle" nil)
    (spotify-dbus-set-property "Shuffle" t)))

(defun spotify-dbus-player-play-track (context-id)
  "Play the given CONTEXT-ID."
  (spotify-dbus-call "OpenUri" context-id))

(defun spotify-dbus-repeating-p ()
  "Check if repeating is on.

Does nothing.  Spotify client broken."
  (string= "Playlist"
   (spotify-dbus-get-property "LoopStatus")))

(defun spotify-dbus-shuffling-p ()
  "Check if shuffeling is on.

Does nothing.  Spotify client broken."
   (spotify-dbus-get-property "Shuffle"))

(defun spotify-dbus-player-play ()
  "Resume play.

Does nothing.  Spotify client broken.  Use PlayPause instead."
  (spotify-dbus-call "Play"))

(defun spotify-dbus-player-pause ()
  "Pause playback."
  (spotify-dbus-call "Pause"))

(defun spotify-dbus-player-playing-p ()
  "Check if Playing."
  (string= "Playing"
	   (spotify-dbus-get-property "PlaybackStatus")))

(defun spotify-dbus-current-track-artist ()
  "Return the artist which is currently playing."
  (car (car (car (cdr (assoc "xesam:artist" (spotify-dbus-get-property "Metadata")))))))

(defun spotify-dbus-current-track-album ()
  "Return the album which is currently playing."
  (car (car (cdr (assoc "xesam:album" (spotify-dbus-get-property "Metadata"))))))

(defun spotify-dbus-current-track-name ()
  "Return the current track name."
  (car (car (cdr (assoc "xesam:title" (spotify-dbus-get-property "Metadata"))))))

(provide 'spotify-dbus)
;;; spotify-dbus ends here
