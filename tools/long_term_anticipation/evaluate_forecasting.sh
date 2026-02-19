
#!/usr/bin/env bash

set -euo pipefail
echo "[DBG] script args: $# -> $*"
echo "[DBG] WORK_DIR will be: ${1-<EMPTY>}"



function run(){
  echo "[DBG] run() args: $# -> $*"


  if [ "${2:-}" = "" ]; then
    echo "run(): missing args (need NAME and CONFIG)" >&2
    exit 2
  fi

  NAME=$1

  CONFIG=$2

  shift 2



  python -m scripts.run_lta \

    --job_name "$NAME" \

    --working_directory "${WORK_DIR}" \

    --cfg "$CONFIG" \

    ${CLUSTER_ARGS} \

    DATA.PATH_TO_DATA_DIR "${EGO4D_ANNOTS}" \

    DATA.PATH_PREFIX "${EGO4D_VIDEOS}" \

    CHECKPOINT_LOAD_MODEL_HEAD True \

    TRAIN.ENABLE False \

    DATA.CHECKPOINT_MODULE_FILE_PATH "" \

    FORECASTING.AGGREGATOR "" \

    FORECASTING.DECODER "" \

    CHECKPOINT_FILE_PATH "" \

    "$@"

}



#-----------------------------------------------------------------------------------------------#



WORK_DIR=$1



EGO4D_ANNOTS=$PWD/data/long_term_anticipation/annotations/

EGO4D_VIDEOS=$PWD/data/long_term_anticipation/clips/

CLUSTER_ARGS="--on_cluster NUM_GPUS 8"



# SlowFast-Transformer

LOAD=$PWD/pretrained_models/long_term_anticipation/lta_slowfast_trf.ckpt

run eval_slowfast_trf \
    configs/Ego4dLTA/MULTISLOWFAST_8x8_R101.yaml \
    FORECASTING.AGGREGATOR TransformerAggregator \
    FORECASTING.DECODER MultiHeadDecoder \
    FORECASTING.NUM_INPUT_CLIPS 4 \
    CHECKPOINT_FILE_PATH "$LOAD" \
    "${@:2}"



