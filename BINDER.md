# Binder (added by patch)

This branch has been patched to make it launchable on
[mybinder.org](https://mybinder.org/).

The patch adds:

- `Dockerfile` — jupyter base + `arduino-cli` + clones the current repo
  into `/home/jovyan/arduino-lib` at build time.
- `requirements.txt` — Python deps for the welcome notebook.
- `apt.txt` — APT packages (mirror of the Dockerfile, for non-Dockerfile builds).
- `postBuild` — refreshes the arduino-cli index + best-effort compiles an example.
- `start` — boot banner + hands off to Jupyter.
- `Welcome.ipynb` — notebook tour of the library.

## Launch

After pushing this branch to your fork:

```
https://mybinder.org/v2/gh/<your-username>/arduino/HEAD
```

The first build takes ~5–10 minutes on the free cluster.

## Removing

To back out, run `git revert <this-commit>` from your fork.
