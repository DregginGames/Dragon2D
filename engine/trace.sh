# trace.sh
#!/bin/bash
export VOGL_CMD_LINE="--vogl_debug --vogl_tracefile trace.bin --vogl_pause"
export LD_PRELOAD=/home/mkalte666/Progg/vogl/vogl_build/libvogltrace64.so
$*
