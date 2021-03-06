base=./mount

if [ $SRC ];
  then echo 'SRC:' $SRC 
else
  SRC='word.jieba.ft'
  echo 'use default SRC word.jieba.ft'
fi 
dir=$base/temp/ai2018/sentiment/tfrecords/$SRC

fold=0
if [ $# == 1 ];
  then fold=$1
fi 
if [ $FOLD ];
  then fold=$FOLD
fi 

model_dir=$base/temp/ai2018/sentiment/model/v9/$fold/$SRC/tf.char.transformer.lm.10epoch/
num_epochs=10

mkdir -p $model_dir/epoch 
cp $dir/vocab* $model_dir
cp $dir/vocab* $model_dir/epoch

exe=./train.py 
if [ "$INFER" = "1"  ]; 
  then echo "INFER MODE" 
  exe=./infer.py 
  model_dir=$1
  fold=0
fi

if [ "$INFER" = "2"  ]; 
  then echo "VALID MODE" 
  exe=./infer.py 
  model_dir=$1
  fold=0
fi
        #bert handle word embedding ..
        #--word_embedding_file=$dir/emb.npy \
        #--decay_target=loss \
        #--decay_patience=1 \
        #--decay_factor=0.8 \
        #--decay_start_epoch_=2. \
python $exe \
        --bert_dir=$base/data/word-emb/chinese_L-12_H-768_A-12 \
        --num_finetune_words=6000 \
        --num_finetune_chars=3000 \
        --model=Transformer \
        --use_char=1 \
        --concat_layers=1 \
        --recurrent_dropout=1 \
        --label_emb_height=20 \
        --fold=$fold \
        --use_label_att=1 \
        --use_self_match=1 \
        --vocab $dir/vocab.txt \
        --model_dir=$model_dir \
        --train_input=$dir/train/'*,' \
        --test_input=$dir/test/'*,' \
        --info_path=$dir/info.pkl \
        --emb_dim 300 \
        --finetune_word_embedding=1 \
        --batch_size 32 \
        --content_limit=512 \
        --buckets=128,256,320,384,512 \
        --batch_sizes 32,16,14,12,6,2 \
        --length_key content \
        --encoder_type=rnn \
        --cell=gru \
        --keep_prob=0.7 \
        --num_layers=2 \
        --rnn_hidden_size=200 \
        --encoder_output_method=topk,att \
        --eval_interval_steps 1000 \
        --metric_eval_interval_steps 1000 \
        --save_interval_steps 1000 \
        --save_interval_epochs=1 \
        --valid_interval_epochs=1 \
        --inference_interval_epochs=1 \
        --freeze_graph=1 \
        --optimizer=bert \
        --learning_rate=5e-5 \
        --num_epochs=$num_epochs \

