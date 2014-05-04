$ sudo -u hdfs hadoop jar /usr/lib/hadoop-0.20/contrib/streaming/hadoop-streaming-0.20.2-cdh3u4.jar \
-numReduceTasks 0 \
-file /home/hikmat/count_mapper.sh \
-input /user/hikmat/input/Words.csv \
-output /user/hikmat/output/WordCount.csv \
-mapper count_mapper.sh \
-verbose