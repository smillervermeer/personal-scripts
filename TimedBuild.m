Model = bdroot(gcs);
tic;
slbuild(Model);
Time = toc;
Minutes = floor(Time/60);
Seconds = rem(Time, 60);
fprintf('Build took %u min %2.2f sec\n',Minutes,Seconds)
