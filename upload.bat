@ECHO OFF
if not exist .git (
	echo This isn't a Git repository, so you can't push to a remote one.
	echo Try downloading it with prepare-for-work.bat
	pause
	exit /b 1
)
:REDO
echo What branch would you like to commit to?  Default branch name is master.  Leave blank for no change.  Also, you can add -b before the branch to create a new branch.  (i.e. -b bugfix)
set /p branch=^>
if "%branch%" equ "" goto nobranch
git checkout %branch%
if %errorlevel% gtr 0 (
	echo There was a problem.  Would you like to try again?
	choice
	if %errorlevel% equ 1 goto redo
	echo Continuing on current branch.
)
:NOBRANCH
echo Adding all files to Git staging area...
echo Executing command `git add *`
git add *
echo Please enter a commit message. (short and sweet please)
set /p message=^>
echo Committing...
echo Executing command `git commit -m "%message%"`
git commit -m "%message%"
echo Please enter a version number.  (e.g. v1.23)  Leave blank for none.
set /p ver=^>
if "%ver%" neq "" (
	echo Executing command git tag %ver%
	git tag %ver%
	echo Pushing to GitHub with tags...
	echo Executing command `git push --tags`
	git push --tags
) else (
	echo Pushing to GitHub...
	echo Executing command `git push`
	git push
)
if %errorlevel% equ 0 (
	echo Success!
	pause
	exit /b
)
echo There was an error pushing to the remote server. Did you forget to prepare your working area before working? Attempting to fix automatically...
echo Executing command `git fetch`
git fetch
echo Executing command `git merge`
git merge
if %errorlevel% gtr 0 (
	echo Uh-oh!  Looks like you will have to fix the error yourself!  All you have to do is open the file with the error in a text editor, decide which block of code that caused the error you want to keep, and run git merge --continue.  To cancel the merge, type git merge --abort.  Good luck!
	pause
	exit /b 1
)
echo Successfully resolved conflict.  Attempting to push again.
if "%ver%" neq "" (
	echo Pushing to GitHub with tags...
	echo Executing command `git push --tags`
	git push --tags
) else (
	echo Pushing to GitHub...
	echo Executing command `git push`
	git push
)
if %errorlevel% gtr 0 (
	echo Looks like it wasn't a merge conflict, you'll have to figure out what the problem is and fix it yourself.  Good luck!
) else(
	echo Successfully uploaded!
)
pause
exit /b