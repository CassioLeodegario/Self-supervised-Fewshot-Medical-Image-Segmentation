#!/bin/bash
# Script v5: Usando dcm2niix com flags corretas (-s y, -z y, -b n)

DATAPATH=./MR
OUTPATH=./niis

# 1. Cria o diretório de saída
mkdir -p "$OUTPATH/T2SPIR"

# 2. Loop através de cada ID de paciente (sid)
for sid in $(ls "$DATAPATH")
do
    echo "--- Processando Paciente $sid ---"
    
    SRC_DIR="$DATAPATH/$sid/T2SPIR/DICOM_anon"
    DEST_DIR="$DATAPATH/$sid/T2SPIR"

    # 3. Roda dcm2niix
    # -o : diretório de saída
    # -s y : modo de arquivo único (CRÍTICO! Isso junta as séries em um só arquivo)
    # -z y : forçar compressão .nii.gz (CRÍTICO!)
    # -b n : não criar BIDS .json (mais limpo)
    # -f %p : nomear o arquivo pelo nome do Protocolo (ex: T2SPIR.nii.gz)
    dcm2niix -o "$DEST_DIR" -s y -z y -b n -f %p "$SRC_DIR"

    # 4. Encontra o ÚNICO arquivo .nii.gz que acabamos de criar
    FILE_TO_MOVE=$(find "$DEST_DIR" -maxdepth 1 -name "*.nii.gz")

    # 5. Verifica e move
    if [ -f "$FILE_TO_MOVE" ]; then
        echo "Arquivo NIfTI criado: $FILE_TO_MOVE"
        mv "$FILE_TO_MOVE" "$OUTPATH/T2SPIR/image_$sid.nii.gz"
        echo "Movido para: $OUTPATH/T2SPIR/image_$sid.nii.gz"
    else
        echo "ERRO: Nenhum arquivo .nii.gz foi encontrado em $DEST_DIR para o paciente $sid"
    fi
done

echo "--- Conversão Concluída ---"