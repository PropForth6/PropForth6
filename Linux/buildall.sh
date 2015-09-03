bash -v buildclean.sh

bash -v buildasm.sh "$@"
bash -v buildinterpreter.sh "$@"

bash -v buildStartKernel.sh "$@"
bash -v buildStartKernelSpin.sh "$@"

bash -v buildopts.sh "$@"

bash -v buildOptKernel.sh "$@"
bash -v buildOptKernelSpin.sh "$@"

bash -v dev/buildDevKernel.sh "$@"
bash -v dev/buildDevKernelSpin.sh "$@"

bash -v mp/buildMpKernel.sh "$@"
bash -v mp/buildMpKernelSpin.sh "$@"

