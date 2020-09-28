# _LOUD_ - Development Git

This is the LOUD Development Repository, where the big brains come together to make LOUD even LOUDER.

## Installing Git-LOUD

Download the latest master.
In your Forged Alliance folder, create a new sub-folder called "Git-LOUD".
Extract the master to the newly created Git-LOUD folder.

You'll need to set up a shortcut to your Supcom executable with the following parameters:
/windowed 1366 768 /nomusic /nomovie /showlog /log "Loud-Dev.log" /init "..\Git-LOUD\bin\SupComDataPath.lua"

Then put this shortcut in your Git-LOUD bin folder. Run the shortcut and wait for the game to open -- It'll be longer than our live distribution as it's loading raw files opposed to .scd archives.
Once the game is open, create a new profile for development.

## Where are my maps?

Git-LOUD loads maps from the "Live" LOUD's 'maps' and 'usermaps' sub-folders. This lets us trim down the Git version from the Live version.