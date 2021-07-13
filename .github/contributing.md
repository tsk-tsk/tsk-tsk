Please make sure that your contribution works locally before sending a Pull Request.
Possibly the best way to check that is to:
- run the tests (by running the test scripts, like `./test/smoke.sh`)
- run the lint job locally `act -j lint`

The second point requires you to have [`act`](https://github.com/nektos/act) installed (which in turn requires Docker).
If you haven't used `act` yet, the first time you run it you will be asked to choose a default Docker image.
Since lint job is not demanding you will be good with all choices, you will likely want the Micro one.
