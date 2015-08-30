BEGIN {
   solver = "MIBS";
   experiment_num = -1;
   counter = -1;
   num_instances = 0;
}

/begin/ {
   experiment_num += 1
   n = split(FILENAME, a, "/");
   sub("16", "1.par", a[1]);
   m = split(a[1], b, ".1.");
   print "Parsing file " b[2] "...";
   experiment_name[experiment_num] = b[2];
}

/Alps_instance/ {
   instance_name = $2
   counter = -1;
   for (i = 0; i < num_instances; i++){
      if (instance[i] == instance_name){
	 counter = i;
      }
   }
   if (counter == -1){
      instance[num_instances] = instance_name;
      counter = num_instances;
      num_instances++;
   } 
}

/nodes processed:/ {
   nodes[experiment_num, counter] = $6;
}

/fully processed:/ {
   nodes[experiment_num, counter] = $7;
}

/gap/ {
   gap[experiment_num, counter] = $6;
   if (gap[experiment_num, counter] > .0001){
      nodes[experiment_num, counter] = -nodes[experiment_num, counter];
      time[experiment_num, counter] = -time[experiment_num, counter];
   }else{
      good[counter] = 1;
   }
}

/wall-clock/ {
   time[experiment_num, counter] = $5;
}

/feasibility/ {
   feas_time[experiment_num, counter] = $5
}

END {
   for (i = 0; i <= experiment_num; i++){
      file = sprintf("%s.summary", experiment_name[i]);
      for (j = 0; j < num_instances; j++){
	 if (good[j] == 1){
	    printf("%-30s %7d   %7.2f\n", instance[j], nodes[i, j], time[i, j]) >> file;
	 }
      }
   }
}