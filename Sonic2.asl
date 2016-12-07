state("SEGAGenesisClassics")
{
	byte seconds : "SEGAGenesisClassics.exe", 0x2D69D9;
	byte minutes : "SEGAGenesisClassics.exe", 0x2D69D6;
	byte lives   : "SEGAGenesisClassics.exe", 0x2D69C7;
	byte level   : "SEGAGenesisClassics.exe", 0x2D6B36; // To prevent Level select from breaking the autosplitter
	byte introPlaying: "SEGAGenesisClassics.exe", 0x2D6BA4;
	byte pressedStart: "SEGAGenesisClassics.exe", 0x2D6981;
	byte pressedStart2: "SEGAGenesisClassics.exe", 0x2D698A;
	byte finalSplit:  "SEGAGenesisClassics.exe", 0x2B4214;
}

start
{
	if (current.seconds == 0 && current.minutes == 0 && current.lives == 3 && current.introPlaying == 1 && current.pressedStart == 255) {
		current.demoStarted = true;
	}
	
	if (current.minutes == 0 && current.lives == 3 && current.introPlaying == 0 && current.demoStarted == true) {
		current.demoStarted = false;
	}

	if (current.seconds == 0 && current.minutes == 0 && current.lives == 3 && current.introPlaying == 0) {
		current.totalTime = 0;
		current.addedTime = 0;
		current.levelCounter = 0;
		return (current.pressedStart == 255 && current.pressedStart2 == 255 && current.demoStarted == false);
	}
}

reset
{
	return (current.lives == 0);
}

init
{
	current.totalTime = 0;
	current.addedTime = 0;
	current.previousLives = 3;
	current.levelCounter = 0;
	current.demoStarted = false;
}

split
{
	// Next level
	if (current.seconds == 0 && current.minutes == 0 && (old.minutes*60 + old.seconds) > 0 && current.lives == current.previousLives && current.levelCounter != 0) {
		current.addedTime += old.minutes*60 + old.seconds;
		current.levelCounter += 1;
		current.previousLives = current.lives;
		return true;
		
	// First level
	} else if (current.seconds == 0 && current.minutes == 0 && (old.minutes*60 + old.seconds) > 17 && current.lives == current.previousLives && current.levelCounter == 0) {
		current.addedTime += old.minutes*60 + old.seconds;
		current.levelCounter = 1;
		return true;
		
	// Final split
	} else if (current.finalSplit == 0 && current.levelCounter == 19 && current.lives == current.previousLives) {
		return current.finalSplit == 0;
	}
}

gameTime
{
	// Restart level
	if (current.seconds == 0 && current.minutes == 0 && (old.minutes*60 + old.seconds) > 0 && current.lives < current.previousLives) {
		current.addedTime += old.minutes*60 + old.seconds;

	// Delay updating previousLives by 1 second, so that restarting doesn't overlap with splitting
	} else if (current.seconds == 1 && current.minutes == 0 && (old.minutes*60 + old.seconds) > 0 && current.lives < current.previousLives) {
		current.previousLives = current.lives;
	}

	// Checkpoint
	if ((old.minutes*60 + old.seconds) > 0 && (current.minutes*60 + current.seconds) > 0 && (current.minutes*60 + current.seconds) < (old.minutes*60 + old.seconds) && current.lives != current.previousLives) {
		current.addedTime += (old.minutes*60 + old.seconds) - (current.minutes*60 + current.seconds);
		current.previousLives = current.lives;
		current.addedTime -= 1;
	}

	// Reset
	if (current.lives == 0) {
		current.totalTime = 0;
		current.addedTime = 0;
		current.previousLives = 3;
		current.demoStarted = false;
		current.levelCounter = 0;
	}

	
	if ((current.minutes*60 + current.seconds) > (old.minutes*60 + old.seconds)) {
		current.totalTime = current.addedTime + current.minutes*60 + current.seconds; // Main counter
	}

	
	// Update extra lives
	if (current.lives > current.previousLives) {
		current.previousLives = current.lives;
	}

	return TimeSpan.FromSeconds(current.totalTime);


}

isLoading
{
	return true;
}
