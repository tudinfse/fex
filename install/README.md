# Installation directories

* To avoid overblowing the size of the container, we download everything into a separate directory (`DATA_PATH`, by default set to `/data/`) and later link sources into the necessary location.

* `common.sh` sets common variables and defines convenience function used in other scripts

* All scripts must have this structure:

```bash
#!/usr/bin/env bash

echo "Installing NAME..."
if [ -z ${PROJ_ROOT} ] ; then echo "Env. variable PROJ_ROOT must be set!" ; exit 1; fi
source ${PROJ_ROOT}/install/common.sh

# Your script

echo "NAME installed"
```