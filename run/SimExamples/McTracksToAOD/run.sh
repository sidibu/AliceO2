#!/usr/bin/env bash

set -x

NEVENTS=100
# launch generator process (for 100 min bias Pythia8 events; no Geant; no geometry)
o2-sim -j 1 -g pythia8pp -n ${NEVENTS} --noDiscOutput --forwardKine --noGeant -m CAVE -e TGeant3 &> sim.log &
SIMPROC=$!

# launch a DPL process (having the right proxy configuration)
# (Note that the option --o2sim-pid is not strictly necessary when only one o2-sim process is running.
#  The socket will than be auto-determined.)

o2-sim-mctracks-proxy -b --nevents ${NEVENTS} --o2sim-pid ${SIMPROC} | o2-sim-mctracks-to-aod -b | o2-analysis-mctracks-to-aod-simple-task -b &
TRACKANAPROC=$!

wait ${SIMPROC}
wait ${TRACKANAPROC}


# the very same analysis task can also directly run on an AO2D with McCollisions and McParticles:
# o2-analysis-mctracks-to-aod-simple-task -b --aod-file <AO2DFile>
