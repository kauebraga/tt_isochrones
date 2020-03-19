# install from local machine
devtools::install_local("misc/opentripplanner-master_mode.zip")

library(opentripplanner)

# download
otp_dl_jar(path = "otp/programs")

# build graph
# Os arquivos de gtfs e .obj devem estar na pasta de cada cidade
opentripplanner::otp_build_graph(otp = "otp/programs/otp.jar", memory = 3000,
                                 dir = "otp", router = "for") 

opentripplanner::otp_build_graph(otp = "otp/programs/otp.jar", memory = 3000,
                                 dir = "otp", router = "bel") 

opentripplanner::otp_build_graph(otp = "otp/programs/otp.jar", memory = 3500,
                                 dir = "otp", router = "spo") 
