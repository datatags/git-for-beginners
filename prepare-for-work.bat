@ECHO OFF
REM If they're running this in a directory that's not a GitHub repository...
if not exist .git goto notarepo
echo Downloading latest version...
echo Executing command `git fetch`
git fetch
echo Updating working directory...
echo Executing command `git merge`
git merge
if %errorlevel% gtr 0 (
	echo There seems to be a problem.  Try running this script in a new(ly cloned) directory.
	pause
	exit /b 1
)
echo Success!
pause
exit /b
:NOTAREPO
echo You are not currently in a cloned repository. Let's clone one.
:REDO
echo What is the username of the author (on GitHub) of the repository you want to download?
set /p author=^>
echo Great. What's the name of their repository that you want to clone?  (If you want to download the wiki of that repository, add .wiki on the end.)
set /p repo=^>
echo Alright. Let's try and download it.
git clone https://github.com/%author%/%repo%.git
if %errorlevel% gtr 0 (
	echo There was a problem downloading the repository.  Did you type the author %author% and the repository name %repo% correctly?
	echo Would you like to try again?
	choice
	if %errorlevel% equ 1 goto redo
	echo Terminating.
	pause
	exit /b 1
) else (
	echo Moving all files to current directory...
	move %repo%\* .
	attrib -h %repo%\.git
	for /d %%d in (%repo%\*) do move %%d .
	attrib +h .git
	rmdir %repo%
	echo Done.
	pause
	exit /b
)
