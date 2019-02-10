function Download()

Model = bdroot(gcs);
SA = Simulink.data.evalinGlobal(Model, 'SoftwareProperties.SourceAddress');
Enovation_MCx_Toolchain.DownloadSoftware(which([Model, '.mcx']), SA)

end
