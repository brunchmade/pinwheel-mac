// Set up the Electron IPC component
const {ipcRenderer} = nodeRequire('electron');



// Play a specific song ('spotifyPlayTrack', 'spotify song id', seconds)

// ipcRenderer.sendSync('spotifyPlayTrack', 'spotify:track:3AhXZa8sUQht0UEdBJgpGc', 1)



// // Play or pause the current song ('spotifyPlayPause', 'spotify song id', seconds)
// (needs song id and seconds just in case the user
// pauses then the room moves on to a new song)

// ipcRenderer.sendSync('spotifyPlayPause', 'spotify:track:3AhXZa8sUQht0UEdBJgpGc', 1)



// Get the current Spotify state. Looks like this:
// state = {
//     volume: 99,
//     position: 232,
//     state: 'playing'
// }

// ipcRenderer.sendSync('spotifyGetState')