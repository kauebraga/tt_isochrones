
library(opentripplanner)

otp_setup(otp = "otp/programs/otp.jar", dir = "otp", router = "for", port = 8080, wait = FALSE)


otp_for <- otp_connect(router = "for")


# otpcon = otp_for
# fromPlace = c(-38.566889, -3.735398)
# mode = "WALK"
# dist = c(3000, 5000, 10000)
# walkSpeed = 1

get_isochrone <- function(dist, walk_speed = 3.6, ...) {
  
  # convert from meters to sec
  x_speed <- walk_speed/3.6
  x_times <- dist/x_speed
  
  iso <- otp_isochrone(cutoffSec = x_times,
                       walkSpeed = x_speed,
                       ...)
  
}


a <- get_isochrone(otpcon = otp_for,
                   fromPlace = c(-38.566889, -3.735398),
                   mode = "WALK",
                   dist = c(1000, 2000, 3000),
                   walk_speed = 3.6)



# a <- otp_isochrone(otpcon = otp_for,
#                    fromPlace = c(-38.566889, -3.735398),
#                    mode = "WALK",
#                    cutoffSec = c(600, 1200, 1800, 2400),
#                    walkSpeed = 1)


library(mapdeck)
set_token("")



mapdeck() %>%
  add_polygon(
    data = a,
    fill_colour = "time",
    legend = TRUE
    
    
  )
  