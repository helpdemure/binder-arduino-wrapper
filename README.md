# Binder wrapper for `analogdevicesinc/arduino`

This is a **thin wrapper repository** that lets you launch the upstream
`analogdevicesinc/arduino` library inside [mybinder.org](https://mybinder.org/)
**without modifying the upstream repo**. At build time it clones the upstream
repo into `/home/jovyan/arduino-lib` inside the container and installs
`arduino-cli` so you can browse, compile, and inspect sketches from a
JupyterLab session in the browser.

## Why this exists

The upstream repo `analogdevicesinc/arduino` contains only C/C++ Arduino
library sources — it has no `requirements.txt` / `environment.yml` / `Dockerfile`,
so `repo2docker` (the engine mybinder.org uses) has nothing to build from and
the launch fails with:

> `No environment specification found.`

This wrapper supplies the environment. The upstream code stays untouched.

## Files in this repo

| File | Role |
|------|------|
| `Dockerfile` | Builds the image: jupyter base + arduino-cli + clones upstream |
| `requirements.txt` | Python deps for the welcome notebook + examples |
| `apt.txt` | APT packages (mirrors Dockerfile, kept for non-Dockerfile builds) |
| `postBuild` | Updates arduino-cli index + best-effort compiles an example |
| `start` | Boot banner + hands off to Jupyter |
| `Welcome.ipynb` | Notebook tour of the cloned library |

## How to launch on mybinder.org

1. Push this folder to a new GitHub repo you own, e.g. `yourname/binder-arduino`.
2. Open this URL in a browser:

   ```
   https://mybinder.org/v2/gh/yourname/binder-arduino/HEAD
   ```

   Or paste `https://github.com/yourname/binder-arduino` into the form on
   <https://mybinder.org/> and click **launch**.

3. The first build downloads jupyter + arduino-cli + the upstream repo and
   takes ~5–10 minutes on the free cluster. Subsequent launches are cached.

## Picking a different upstream ref

The `Dockerfile` pins the upstream commit `d5946b9` (the latest `master`
HEAD at the time this wrapper was built). To track a newer commit, branch,
or tag, change the `ARG ARDUINO_REPO_REF=d5946b9` line near the top of the
`Dockerfile`, commit, and re-launch.

## Alternative: patch your own fork

If you have forked `analogdevicesinc/arduino` and want the Binder config to
live **inside** that fork instead of in a separate wrapper repo, apply
`analogdevicesinc-arduino-binder.patch` (shipped alongside this bundle) from
the root of your fork:

```bash
git clone https://github.com/<your-username>/arduino
cd arduino
git apply /path/to/analogdevicesinc-arduino-binder.patch
git add Dockerfile requirements.txt apt.txt postBuild start Welcome.ipynb
git commit -m "Add Binder configuration"
git push
```

Then launch:

```
https://mybinder.org/v2/gh/<your-username>/arduino/HEAD
```

## What you can do inside the resulting Binder

- Browse the upstream library source under `/home/jovyan/arduino-lib`.
- Use `arduino-cli` to compile example sketches for `arduino:avr:uno` (no
  hardware flashing — this is a cloud container).
- Read the bundled `Welcome.ipynb` for a guided tour and code snippets.
- Edit the library source live in JupyterLab. Changes do not persist after
  the session ends unless you export them (File → Download).

## Notes / limitations

- Binder sessions run in the cloud with no real Arduino hardware attached,
  so USB serial I/O (`pyserial`) won't talk to a real board. You can still
  import `pyserial` and run pure-Python examples that don't need a port.
- The free mybinder.org cluster has a 4 GB RAM / ~10 min build limit. If
  the build times out, switch `FROM jupyter/minimal-notebook` to a smaller
  base or trim `requirements.txt`.
- This wrapper is unaffiliated with Analog Devices. All upstream source
  remains the property of its authors under their chosen license.
